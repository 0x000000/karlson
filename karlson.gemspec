# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'karlson/version'

Gem::Specification.new do |spec|
  spec.name          = 'karlson'
  spec.version       = Karlson::VERSION
  spec.authors       = ['Alexander Rudenka']
  spec.email         = ['mur.mailbox@gmail.com']
  spec.summary       = 'Compact text (JSON-based) protocol with versioning and type checking'
  spec.description   = ''
  spec.homepage      = 'https://github.com/0x000000/karlson'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'rake'
end
