# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fe/version'

Gem::Specification.new do |spec|
  spec.name        = "iron_fixture_extractor"
  spec.version     = Fe::VERSION
  spec.authors     = ["Ian Whitney", "Debbie Gillespie", "Davin Lagerroos", "Joe Goggins"]
  spec.email       = ["asrwebteam@umn.edu"]
  spec.description = %q{When object factories don't work because your data is too complex and creating manual fixtures is cumbersome and brittle: Iron Fixture Extractor (for Rails/ActiveRecord) }
  spec.summary     = %q{Simplified dynamic fixture extraction for ActiveRecord}
  spec.homepage    = "https://github.com/umn-asr/iron_fixture_extractor"
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  spec.add_runtime_dependency "activerecord", "~> 3.2.1"
  spec.add_runtime_dependency "activesupport", "~> 3.2.1"
  spec.add_development_dependency "rspec", "~> 2.14.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "shoulda"
end
