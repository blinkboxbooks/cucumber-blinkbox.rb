# coding: utf-8
lib = File.join(File.dirname(__FILE__),'lib')
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "cucumber-blinkbox"
  spec.version       = ::File.read("VERSION")
  spec.authors       = ["blinkbox books"]
  spec.email         = ["jphastings@blinkbox.com"]
  spec.description   = %q{blinkbox books specific cucumber test helpers}
  spec.summary       = %q{blinkbox books specific cucumber test helpers}
  spec.homepage      = "http://blinkboxbooks.github.io/"
  spec.license       = "MIT"

  spec.files         = [*Dir["{lib,bin,spec}/**/*.rb"], "VERSION"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 4.0"
  spec.add_runtime_dependency "cucumber", "~> 1.3"
  spec.add_runtime_dependency "httpclient"
  spec.add_runtime_dependency "http_capture"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 2.99"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber-helpers"
end
