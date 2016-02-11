# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano-fault-tolerant/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-fault-tolerant"
  spec.version       = CapistranoFaultTolerant::VERSION
  spec.authors       = ["Kir Shatrov"]
  spec.email         = ["shatrov@me.com"]

  spec.summary       = %q{Brings fault tolerant command to Capistrano}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", "~> 3.4"
  spec.add_dependency "sshkit", "~> 1.8"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
