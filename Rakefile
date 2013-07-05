#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

desc "Run the rspec test sweet"
task :test do
  puts "Running specs in /spec."
  sh "bundle exec rspec"
end
task :default => 'test'

desc "Open an irb session preloaded with this library"
task :console do
  sh "bundle exec irb -rubygems -I lib -I spec -r spec_helper -r fe"
end
