# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-rsync-back/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-rsync-back"
  spec.version       = VagrantPlugins::RsyncBack::VERSION
  spec.authors       = ["Steven Merrill"]
  spec.email         = ["steven.merrill@gmail.com"]
  spec.summary       = %q{Rsync in reverse to pull files from your Vagrant rsynced folders.}
  spec.description   = %q{Rsync in reverse to pull files from your Vagrant rsynced folders.}
  spec.homepage      = ""
  spec.license       = "MIT"

  # @TODO: Remove example files from the built gem.
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
