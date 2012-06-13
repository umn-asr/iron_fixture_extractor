class FeTestEnv
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
    def destroy_tmp_test_stuff #sqlite dbs and fixture files
      FileUtils.rm_rf Dir.glob("#{self.tmp_directory}/*")
    end
    def tmp_directory
      File.join(File.dirname(__FILE__), "tmp")
    end
    def establish_connection
      ActiveRecord::Base.establish_connection(self.connections[self.the_env])
      ActiveRecord::Base.connection
    end
    def connections
      YAML::load_file(File.join(File.dirname(__FILE__), 'config', 'database.yml'))
    end
    def load_models
      self.models.each do |x|
        require "models/#{x}"
      end
    end

    def unload_models
      # DOESN"T WORK!!!!!!!!!
      self.models.each do |x|
        Object.send(:remove_const, "::#{x.to_s.capitalize}")
      end
    end
    def make_fixtures_dir_and_set_fixtures_root
      FileUtils.mkdir_p FeTestEnv.fixtures_root
      Fe.fixtures_root = FeTestEnv.fixtures_root
    end
    attr_accessor :the_env

    def setup_methods
      @the_env ||= 'fake_production'
      [
       :make_fixtures_dir_and_set_fixtures_root,
       :load_models,
       :establish_connection,
       :migrate_schema,
       :migrate_fake_production_data]
    end
    def setup
      self.setup_methods.each {|m| send m}
    end
    def teardown_methods
      [
       :destroy_tmp_test_stuff
      ]
    end
    def teardown
      self.teardown_methods.each {|m| send m}
    end
    def recreate_schema_without_data
      f=File.join(self.tmp_directory,"#{self.the_env}.sqlite3")
      begin
        FileUtils.rm f
      rescue
        puts "#{f} does not exist"
      end
      [:load_models, :establish_connection,:migrate_schema].each {|m| send m}
    end
    def reload
      teardown
      setup
    end
  end
end

