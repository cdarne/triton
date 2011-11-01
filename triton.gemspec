# -*- encoding: utf-8 -*-
require "#{File.dirname(__FILE__)}/lib/triton/version"

Gem::Specification.new do |s|
  s.add_development_dependency "minitest", "~> 2.7.0"
  s.add_development_dependency "mocha", "~> 0.10.0"
  s.add_development_dependency "bundler", "~> 1.0"
  s.authors = ["Cédric Darné"]
  s.description = %q{Triton is an implementation of the event/listener pattern like EventEmitter on Node.js}
  s.email = "cedric.darne@gmail.com"
  s.extra_rdoc_files = ['LICENSE.md', 'README.md']
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/cdarne/triton'
  s.name = "triton"
  s.require_path = ['lib']
  s.required_ruby_version = ">= 1.9.2"
  s.required_rubygems_version = Gem::Requirement.new('>= 1.8.0')
  s.summary = s.description
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Triton::VERSION.dup
end