# An object for setting up dummy source and target environments 
# used through the test suite
#
class FeTestEnv
  attr_reader :root_path
  # caller should specify full path
  # by default it isn't lazy with initialization of tmp dir + loading models
  def initialize(root_path, options = {:lazy => false})
    @root_path = root_path
    if !options[:lazy]
      bomb_and_rebuild
    end
  end

  # INITIALIZATION HELPERS
  def bomb_and_rebuild
    Fe.fixtures_root = self.fe_fixtures_dir
    initialize_tmp
    load_models
    connect_to_source
    create_tables_in('source')
    create_rows_in('source')
  end

  def initialize_tmp
    FileUtils.rm_rf(tmp_dir)
    FileUtils.mkdir_p(tmp_dir)
    FileUtils.mkdir_p(fe_fixtures_dir)
    self
  end
  def load_models
    model_files.each do |m|
      load m
    end
    self
  end

  # PUBLIC API
  def create_tables_in(string)
    send("connect_to_#{string}")
    run_migrations
  end
  def create_rows_in(string)
    send("connect_to_#{string}")
    run_data_migrations
  end
  def connect_to_source
    ActiveRecord::Base.establish_connection(database_dot_yml_hash['source'])
  end
  def connect_to_target
    ActiveRecord::Base.establish_connection(database_dot_yml_hash['target'])
  end

  # WORKER HELPERS
  def run_migrations
    if ActiveRecord.version >= Gem::Version.new("5.2")
      migration_context = ActiveRecord::MigrationContext.new("#{root_path}/migrations/")
      migration_context.migrate
    else
      ActiveRecord::Migrator.migrate("#{root_path}/migrations/",nil)
    end
  end

  def run_data_migrations
    if ActiveRecord.version >= Gem::Version.new("5.2")
      migration_context = ActiveRecord::MigrationContext.new("#{root_path}/data_migrations/")
      migration_context.migrate
    else
      ActiveRecord::Migrator.migrate("#{root_path}/data_migrations/",nil)
    end
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

