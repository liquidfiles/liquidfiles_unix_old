# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'liquidfiles/version'

Gem::Specification.new do |spec|
  spec.name          = "liquidfiles"
  spec.version       = LiquidFiles::VERSION
  spec.authors       = ["Marcin Harasimowicz"]
  spec.email         = ["support@liquidfiles.net"]
  spec.description   = %q{ LiquidFiles.net CLI}
  spec.summary       = "LiquidFiles.net CLI"
  spec.homepage      = "https://github.com/liquidfiles/liquidfiles_unix"
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "webmock", "~> 1.15"

  spec.add_runtime_dependency "curb", "~> 0.8"
  spec.add_runtime_dependency "thor", "~> 0.18"
  spec.add_runtime_dependency "nokogiri", "~> 1.6"
  spec.add_runtime_dependency "gem-man", "~> 0.3"
  spec.add_runtime_dependency "ronn", "~> 0.7"
  spec.add_runtime_dependency "ruby-progressbar", "~> 1.2"
end
