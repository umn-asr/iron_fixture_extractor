# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fe/version'

Gem::Specification.new do |gem|
  gem.name          = "iron_fixture_extractor"
  gem.version       = Fe::VERSION
  gem.authors     = ["Ian Whitney", "Debbie Gillespie", "Davin Lagerroos", "Joe Goggins"]
  gem.email       = ["asrwebteam@umn.edu"]
  gem.description = %q{When object factories don't work because your data is too complex and creating manual fixtures is cumbersome and brittle: Iron Fixture Extractor (for Rails/ActiveRecord) }
  gem.summary     = %q{Simplified dynamic fixture extraction for ActiveRecord}
  gem.homepage    = "https://github.com/umn-asr/iron_fixture_extractor"
  gem.license = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "activerecord", "~> 4.0"
  gem.add_runtime_dependency "activesupport", "~> 4.0"
  gem.add_development_dependency "rspec", "~> 2.14.0"
  gem.add_development_dependency "rspec-fire", "= 1.3.0"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "shoulda"
end
