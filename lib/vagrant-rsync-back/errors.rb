require "vagrant"

module VagrantPlugins
  module RsyncBack
    module Errors
      class VagrantRsyncBackError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_rsync_back.errors")
      end

      class OnlyOSXLinuxSupportError < VagrantRsyncBackError
        error_key(:only_osx_linux_support)
      end

      class Vagrant15RequiredError < VagrantRsyncBackError
        error_key(:vagrant_15_required)
      end
    end
  end
end
