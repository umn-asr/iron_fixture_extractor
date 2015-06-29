require 'rspec'
require 'rspec/fire'
require 'iron_fixture_extractor'
# Require test helpers like FeTestEnv
Dir[File.join(File.dirname(__FILE__),"support/**/*.rb")].each {|f| require f}
# Don't show me the migration up + down crap
ActiveRecord::Migration.verbose = false
# Show be colors!
RSpec.configure do |config|
  config.failure_color = :magenta
  config.tty = true
  config.color = true
  config.include(RSpec::Fire)
end

require 'sqlite3'
FeTestEnv.instance = FeTestEnv.new(File.join(File.dirname(__FILE__),'dummy_environments','sqlite','dummy1'))
