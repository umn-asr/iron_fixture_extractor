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
end

ENV['fe_test_type'] ||= 'sqlite'
case ENV['fe_test_type']
when 'oracle'
  # someday we might have tests for different adapters
when 'mysql'
when 'postgres'
when 'sqlite'
  require 'sqlite3'
  ENV['fe_test_env'] ||= 'dummy1'
  FeTestEnv.instance = FeTestEnv.new(File.join(File.dirname(__FILE__),'dummy_environments','sqlite','dummy1'))
else
  raise 'invalid ENV[fe_test_type]'
end
