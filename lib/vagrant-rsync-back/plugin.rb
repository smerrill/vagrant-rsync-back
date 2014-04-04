begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant gatling rsync plugin must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.5.1"
  raise Errors::Vagrant15RequiredError
end

module VagrantPlugins
  module RsyncBack
    class Plugin < Vagrant.plugin("2")
      name "Rsync Back"
      description <<-DESC
      Rsync back from the guest to the host.
      DESC

      # This initializes the internationalization strings.
      def self.setup_i18n
        I18n.load_path << File.expand_path("locales/en.yml", RsyncBack.source_root)
        I18n.reload!
      end

      command "rsync-back" do
        setup_i18n

        require_relative "command/rsync_back"
        RsyncBackCommand
      end
    end
  end
end
