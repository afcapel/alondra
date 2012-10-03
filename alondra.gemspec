# -*- encoding: utf-8 -*-
require File.expand_path('../lib/alondra/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "alondra"
  s.summary = "Add real time capabilities to your rails app"
  s.description = "Add real time capabilities to your rails app"
  s.version = Alondra::VERSION
  s.authors = ['Alberto F. Capel', 'Ryan LeCompte']

  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Dependencies
  s.add_dependency('daemons')
  s.add_dependency('uuidtools')
  s.add_dependency('rails', '>= 3.1.0')
  s.add_dependency('em-websocket')
  s.add_dependency('em-zeromq', '>= 0.3.1')
end
