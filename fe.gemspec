# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fe/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joe Goggins"]
  gem.email         = ["goggins@umn.edu"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fe"
  gem.require_paths = ["lib"]
  gem.version       = Fe::VERSION
  gem.add_runtime_dependency "activerecord", "~> 3.2.1"
  gem.add_runtime_dependency "activesupport", "~> 3.2.1"
  gem.add_development_dependency "shoulda", "~> 3.0.1"
  gem.add_development_dependency "sqlite3"
end
