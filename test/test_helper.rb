require 'rubygems'
require 'bundler'
Bundler.setup
require 'shoulda'
require 'fe'
# TEMP, COMMENT OUT IF NEEDED
require 'sqlite3'
require 'ruby-debug'

class TestConfig
  class << self
    def models
      [:post,:comment,:author,:group,:group_member]
    end
    def model_classes
      self.models.map {|x| x.to_s.classify.constantize}
    end
    def fixtures_root
      'test/tmp/fe_fixtures'
    end
    def migrate_schema
      ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__),'migrations'),nil)
    end
    def migrate_fake_production_data
      ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__),'test_data_migrations'),nil)
    end
    def destroy_fixtures
      begin
        FileUtils.rm_rf "#{self.fixtures_root}/*"
      rescue 
        puts "Couldn't rm_rf fixtures at #{self.fixtures_root}"
      end
    end
    def destroy_sqlite_databases
      begin
        FileUtils.rm self.connections['fake_production']['database']
      rescue 
        puts "Couldn't rm #{self.connections['fake_production']['database']}"
      end
    end
    def establish_connection
      ActiveRecord::Base.establish_connection(self.connections[self.the_env])
      ActiveRecord::Base.connection
    end
    def connections
      YAML::load_file(File.join(File.dirname(__FILE__), 'config', 'database.yml'))
    end
    def require_models
      self.models.each do |x|
        require "models/#{x}"
      end
    end
    attr_accessor :the_env
    def load!
      @the_env ||= 'fake_production'
      [
       :require_models,
       :establish_connection,
       :migrate_schema,
       :migrate_fake_production_data,
       :destroy_fixtures, 
       :destroy_sqlite_databases
      ].each do |m|
        TestConfig.send(m)
      end
    end
  end
end
TestConfig.load!
