#!/usr/bin/env rake
begin
  require 'bundler/setup'
  require "bundler/gem_tasks"
  require 'rake/testtask'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test
