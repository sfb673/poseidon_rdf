# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'poseidon_rdf/version'

Gem::Specification.new do |spec|
  spec.name          = "poseidon_rdf"
  spec.version       = PoseidonRdf::VERSION
  spec.authors       = ["Peter Menke"]
  spec.email         = ["pmenke@googlemail.com"]
  spec.summary       = %q{A collection of mixins for providing RDF information out of existing objects.}
  spec.description   = %q{POSEIdON (short for “Pimp your Objects with SEmantic InformatiON”) is a small library that lets you add RDF information to classes and their instances. It can also add methods as_rdf and to_rdf to those classes and objects that can be used to retrieve RDF representations in various formats, based on the functionality provided by the RDF gem.}
  spec.homepage      = ""
  spec.license       = "GNU LGPL v3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency 'rdf', '~> 1.1'
  spec.add_runtime_dependency 'rdf-turtle', '~> 1.1'
  spec.add_runtime_dependency 'rdf-rdfxml', '~> 1.1'
  spec.add_runtime_dependency 'nokogiri'
end
