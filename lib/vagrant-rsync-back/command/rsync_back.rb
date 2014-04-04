require "log4r"
require "optparse"

require "vagrant"

# MONKEYPATCH!!11!1!
module VagrantPlugins
  module SyncedFolderRSync
    class RsyncHelper
      def self.get_rsync_command(machine, ssh_info, opts)
        # Folder info
        guestpath = opts[:guestpath]
        hostpath  = opts[:hostpath]
        hostpath  = File.expand_path(hostpath, machine.env.root_path)
        hostpath  = Vagrant::Util::Platform.fs_real_path(hostpath).to_s

        if Vagrant::Util::Platform.windows?
          # rsync for Windows expects cygwin style paths, always.
          hostpath = Vagrant::Util::Platform.cygwin_path(hostpath)
        end

        # Make sure the host path ends with a "/" to avoid creating
        # a nested directory...
        if !hostpath.end_with?("/")
          hostpath += "/"
        end

        # Folder options
        opts[:owner] ||= ssh_info[:username]
        opts[:group] ||= ssh_info[:username]

        # Connection information
        username = ssh_info[:username]
        host     = ssh_info[:host]
        rsh = [
          "ssh -p #{ssh_info[:port]} -o StrictHostKeyChecking=no",
          ssh_info[:private_key_path].map { |p| "-i '#{p}'" },
        ].flatten.join(" ")

        # Exclude some files by default, and any that might be configured
        # by the user.
        excludes = ['.vagrant/']
        excludes += Array(opts[:exclude]).map(&:to_s) if opts[:exclude]
        excludes.uniq!

        # Get the command-line arguments
        args = nil
        args = Array(opts[:args]) if opts[:args]
        args ||= ["--verbose", "--archive", "--delete", "-z"]

        # On Windows, we have to set the chmod flag to avoid permission issues
        if Vagrant::Util::Platform.windows?
          args << "--chmod=ugo=rwX"
        end

        # Build up the actual command to execute
        [
          "rsync",
          args,
          "-e", rsh,
          excludes.map { |e| ["--exclude", e] },
          hostpath,
          "#{username}@#{host}:#{guestpath}",
        ]
      end

      def self.rsync_single(machine, ssh_info, opts, rsync_back=false)
        command_parts = get_rsync_command(machine, ssh_info, opts)
        command_parts = command_parts.concat(command_parts.slice!(-2, 2).reverse) if rsync_back
        command = command_parts.flatten
        # The working directory should be the root path
        command_opts = {}
        command_opts[:workdir] = machine.env.root_path.to_s

        machine.ui.info(I18n.t(
          "vagrant.rsync_folder", guestpath: guestpath, hostpath: hostpath))
        if excludes.length > 1
          machine.ui.info(I18n.t(
            "vagrant.rsync_folder_excludes", excludes: excludes.inspect))
        end

        # If we have tasks to do before rsyncing, do those.
        if machine.guest.capability?(:rsync_pre)
          machine.guest.capability(:rsync_pre, opts) unless rsync_back
        end

        r = Vagrant::Util::Subprocess.execute(*(command + [command_opts]))
        if r.exit_code != 0
          raise Vagrant::Errors::RSyncError,
            command: command.join(" "),
            guestpath: guestpath,
            hostpath: hostpath,
            stderr: r.stderr
        end

        # If we have tasks to do after rsyncing, do those.
        if machine.guest.capability?(:rsync_post)
          machine.guest.capability(:rsync_post, opts) unless rsync_back
        end
      end
    end
  end
end

module VagrantPlugins
  module RsyncBack
    class RsyncBackCommand < Vagrant.plugin(2, :command)
      include Vagrant::Action::Builtin::MixinSyncedFolders

      def self.synopsis
        "syncs rsync synced folders from remote machine"
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant rsync-back [vm-name]"
          o.separator ""
        end

        # Parse the options and return if we don't have any target.
        argv = parse_options(opts)
        return if !argv

        # Go through each machine and perform the rsync
        error = false
        with_target_vms(argv) do |machine|
          if !machine.communicate.ready?
            machine.ui.error(I18n.t("vagrant.rsync_communicator_not_ready"))
            error = true
            next
          end

          # Determine the rsync synced folders for this machine
          folders = synced_folders(machine)[:rsync]
          next if !folders || folders.empty?

          # Get the SSH info for this machine so we can access it
          ssh_info = machine.ssh_info

          # Sync them!
          folders.each do |id, folder_opts|
            RsyncHelper.rsync_single(machine, ssh_info, folder_opts, true)
          end
        end

        return error ? 1 : 0
      end
    end
  end
end
