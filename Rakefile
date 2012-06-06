#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
task :default => 'test'

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r fe.rb"
end


