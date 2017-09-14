# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "money/version"

Gem::Specification.new do |spec|
  spec.name          = "money"
  spec.version       = Money::VERSION
  spec.authors       = ["Karol Moroz"]
  spec.email         = ["k.j.moroz@gmail.com"]

  spec.summary       = %q{A simple gem to perform currency conversion and arithmetics.}
  spec.description   = %q{This is a simple, two-class gem to perform currency conversion and arithmetics using different currencies. It was written in response to a coding challenge as a part of the recruitment process at Dievision, a German media agency specializing in Web design and full stack development. It uses the Fixer.io to fetch currency exchange rates and is unit-tested using RSpec and Webmock.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
