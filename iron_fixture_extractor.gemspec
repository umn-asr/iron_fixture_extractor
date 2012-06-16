# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fe/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joe Goggins"]
  gem.email         = ["goggins@umn.edu"]
  gem.description   = %q{When object factories don't work because your data is too complex and creating manual fixtures is cumbersome and brittle: Iron Fixture Extractor (for Rails/ActiveRecord) }
  gem.summary       = %q{Simplified dynamic fixture extraction for ActiveRecord}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "iron_fixture_extractor"
  gem.require_paths = ["lib"]
  gem.version       = Fe::VERSION
  gem.add_runtime_dependency "activerecord", "~> 3.2.1"
  gem.add_runtime_dependency "activesupport", "~> 3.2.1"
  gem.add_development_dependency "shoulda", "~> 3.0.1"
  gem.add_development_dependency "sqlite3"
end
