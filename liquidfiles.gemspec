# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'liquidfiles/version'

Gem::Specification.new do |spec|
  spec.name          = "LiquidFiles"
  spec.version       = LiquidFiles::VERSION
  spec.authors       = ["Marcin Harasimowicz"]
  spec.email         = ["support@liquidfiles.net"]
  spec.description   = %q{ LiquidFiles.net CLI}
  spec.summary       = ""
  spec.homepage      = "https://github.com/liquidfiles/liquidfiles_unix"
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "fakeweb"

  spec.add_runtime_dependency "curb"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "nokogiri"
end
