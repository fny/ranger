# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ranger/version'

Gem::Specification.new do |spec|
  spec.name          = "ranger"
  spec.version       = Ranger::VERSION
  spec.authors       = ["Faraz Yashar"]
  spec.email         = ["faraz.yashar@gmail.com"]

  spec.summary       = "Intervals, maps, tables, and more coming soon."
  spec.homepage      = "https://github.com/fny/ranger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.6"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "pry"
end
