require 'rubygems'
require 'bundler'
Bundler.setup
require 'shoulda'
require 'fe'
require 'sqlite3'
@connections = YAML::load_file(File.join(File.dirname(__FILE__), 'config', 'database.yml'))

require 'fileutils'
begin
  FileUtils.rm @connections['sqlite']['database']
rescue
end
ActiveRecord::Base.establish_connection(@connections['sqlite'])
ActiveRecord::Base.connection


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
  end
end


TestConfig.models.each do |x|
  require "models/#{x}"
end
ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__),'migrations'),nil)
ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__),'test_data_migrations'),nil)
