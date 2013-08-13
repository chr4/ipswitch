# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ipswitch/version'

Gem::Specification.new do |spec|
  spec.name          = 'ipswitch'
  spec.version       = Ipswitch::VERSION
  spec.authors       = ['Chris Aumann']
  spec.email         = ['me@chr4.org']
  spec.description   = %q{Migrate IP addresses on the fly to other hosts without downtime}
  spec.summary       = %q{Migrate IP addresses on the fly to other hosts without downtime}
  spec.homepage      = 'https://github.com/chr4/ipswitch'
  spec.license       = 'GPLv3'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'

  spec.add_runtime_dependency 'thor'
  spec.add_runtime_dependency 'net-ssh'
  spec.add_runtime_dependency 'ipaddress'
  spec.add_runtime_dependency 'rainbow'
end
