# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pandorabots/version'

Gem::Specification.new do |spec|
  spec.name          = "pandorabots_api"
  spec.version       = Pandorabots::VERSION
  spec.authors       = ["Takuya Tsuchida"]
  spec.email         = ["takuya.tsuchida@spontena.com"]
  spec.summary       = %q{Pandorabots API module for Ruby.}
  spec.description   = ""
  spec.homepage      = "https://github.com/spontena/pb-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
