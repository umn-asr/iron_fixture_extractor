#joe-gogginss-macbook-pro:iron_fixture_extractor goggins$ cp -R test/config spec/dummy_environments/sqlite/dummy1/
#joe-gogginss-macbook-pro:iron_fixture_extractor goggins$ cp -R test/migrations spec/dummy_environments/sqlite/dummy1/
#joe-gogginss-macbook-pro:iron_fixture_extractor goggins$ cp -R test/models/ spec/dummy_environments/sqlite/dummy1/
#joe-gogginss-macbook-pro:iron_fixture_extractor goggins$ ls test/tmp/
#fake_production.sqlite3	fe_fixtures
#joe-gogginss-macbook-pro:iron_fixture_extractor goggins$ mkdir -p spec/dummy_environments/sqlite/dummy1/spec/fe_fixtures
#joe-gogginss-macbook-pro:iron_fixture_extractor goggins$ touch spec/dummy_environments/sqlite/dummy1/spec/fe_fixtures/.gitkeep
#joe-gogginss-macbook-pro:iron_fixture_extractor goggins$ mkdir spec/dummy_environments/sqlite/dummy1/db
#joe-gogginss-macbook-pro:iron_fixture_extractor goggins$ touch !$/.gitkeep
#touch spec/dummy_environments/sqlite/dummy1/db/.gitkeep
class FeTestEnv
  attr_reader :root_path
  def initialize(root_path) # caller should specify full path
    @root_path = root_path
  end
  # PUBLIC API

  def connect_to_source
    ActiveRecord::Base.establish_connection(database_dot_yml_hash['source'])
  end

  def connect_to_target
    ActiveRecord::Base.establish_connection(database_dot_yml_hash['target'])
  end
  def setup
       #:make_fixtures_dir_and_set_fixtures_root,
       #:load_models,
       #:establish_connection,
       #:migrate_schema,
       #:migrate_fake_production_data]
    make_fixtures_dir_and_set_fe_fixtures_root
    load_models 
    #load_migrations
  end

  def make_fixtures_dir_and_set_fe_fixtures_root
    FileUtils.mkdir_p(fe_fixtures_dir)
    Fe.fixtures_root = fe_fixtures_dir
  end

  def load_models
    model_files.each do |m|
      load m
    end
  end
  def teardown
  end
  def reload
  end

  # File & directory location accessors (provides full path)
  # --------------------------------------------------------
  #
  def database_dot_yml_file
    File.join(root_path,'config','database.yml')  
  end
  def database_dot_yml_hash
    YAML::load_file(database_dot_yml_file)
  end
  def migration_files
    Dir["#{root_path}/migrations/**/*.rb"]
  end
  def model_files
    Dir["#{root_path}/models/**/*.rb"]
  end
  def tmp_dir
    File.expand_path(File.join(File.dirname(__FILE__),'..','tmp'))
  end
  def fe_fixtures_dir
    File.join(tmp_dir,'fe_fixtures')  
  end
  def sqlite_db_dir
    tmp_dir
  end

  # Singleton-style
  class << self
    def instance
      raise "spec_helper.rb is supposed to set @instance...bug there yo" if @instance.nil?
      @instance
    end
    def instance=(i)
      @instance = i
    end
  end
end
#class FeTestEnv
  #class << self
    #def models
      #[:serialized_attribute_encoder,:complex_thing,:post,:comment,:author,:group,:group_member,:different_post, :user, :'user/admin',:'user/jerk']
    #end
    #def model_classes
      #self.models.map {|x| x.to_s.classify.constantize}
    #end
    #def fixtures_root
      #'test/tmp/fe_fixtures'
    #end
    #def migrate_schema
      #ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__),'migrations'),nil)
    #end
    #def migrate_fake_production_data
      #ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__),'test_data_migrations'),nil)
    #end
    #def destroy_tmp_test_stuff #sqlite dbs and fixture files
      #FileUtils.rm_rf Dir.glob("#{self.tmp_directory}/*")
    #end
    #def tmp_directory
      #File.join(File.dirname(__FILE__), "tmp")
    #end
    #def establish_connection
      #ActiveRecord::Base.establish_connection(self.connections[self.the_env])
      #ActiveRecord::Base.connection
    #end
    #def connections
      #YAML::load_file(File.join(File.dirname(__FILE__), 'config', 'database.yml'))
    #end
    #def load_models
      #self.models.each do |x|
        #require "models/#{x}"
      #end
    #end

    #def unload_models
      ## DOESN"T WORK!!!!!!!!!
      #self.models.each do |x|
        #Object.send(:remove_const, "::#{x.to_s.capitalize}")
      #end
    #end
    #def make_fixtures_dir_and_set_fixtures_root
      #FileUtils.mkdir_p FeTestEnv.fixtures_root
      #Fe.fixtures_root = FeTestEnv.fixtures_root
    #end
    #attr_accessor :the_env

    #def setup_methods
      #@the_env ||= 'fake_production'
      #[
       #:make_fixtures_dir_and_set_fixtures_root,
       #:load_models,
       #:establish_connection,
       #:migrate_schema,
       #:migrate_fake_production_data]
    #end
    #def setup
      #self.setup_methods.each {|m| send m}
    #end
    #def teardown_methods
      #[
       #:destroy_tmp_test_stuff
      #]
    #end
    #def teardown
      #self.teardown_methods.each {|m| send m}
    #end
    #def recreate_schema_without_data
      #f=File.join(self.tmp_directory,"#{self.the_env}.sqlite3")
      #begin
        #FileUtils.rm f
      #rescue
        #puts "#{f} does not exist"
      #end
      #[:load_models, :establish_connection,:migrate_schema].each {|m| send m}
    #end
    #def reload
      #teardown
      #setup
    #end
  #end
#end

