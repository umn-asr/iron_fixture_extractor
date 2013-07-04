require 'spec_helper'

describe "Outer loop" do
  before(:each) do
    @sqlite_env_path = File.join(File.dirname(__FILE__),'dummy_environments','sqlite','dummy1')
    @fe_test_env = FeTestEnv.new(@sqlite_env_path)
    FileUtils.rm_rf(@fe_test_env.tmp_dir)
    FileUtils.mkdir_p(@fe_test_env.tmp_dir)
    FileUtils.rm_rf(@fe_test_env.fe_fixtures_dir)
    FileUtils.mkdir_p(@fe_test_env.fe_fixtures_dir)
  end
  it "key test env file paths & dirs exist" do
    expect(File.directory?(@fe_test_env.root_path)).to eql(true)
    expect(File.exist?(@fe_test_env.database_dot_yml_file)).to eql(true)
    [:migration_files, :model_files].each do |f|
      expect(@fe_test_env.send(f)).to be_a_kind_of(Array)
      @fe_test_env.send(f).each do |tf|
        expect { load tf }.to_not raise_exception
      end
    end

    expect(File.directory?(@fe_test_env.tmp_dir)).to eql(true)
    expect(File.directory?(@fe_test_env.fe_fixtures_dir)).to eql(true)
    expect(File.directory?(@fe_test_env.sqlite_db_dir)).to eql(true)
  end

  it "can connect to source and target",:focus => true do
    # SOURCE
    @fe_test_env.connect_to_source
    source_db = @fe_test_env.database_dot_yml_hash['source']['database']
    expect(ActiveRecord::Base.connection).to be_a_kind_of(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
    ActiveRecord::Base.connection.tables # hitting it creates the file
    expect(File.exists?(source_db)).to eql(true)

    # TARGET
    #
    @fe_test_env.connect_to_target
    target_db = @fe_test_env.database_dot_yml_hash['target']['database']
    expect(ActiveRecord::Base.connection.instance_variable_get(:@config)[:database]).to eql(target_db)
    ActiveRecord::Base.connection.tables # hitting it creates the file
    expect(File.exists?(target_db)).to eql(true)
  end
  it "should load and unload models" do
    # CONTINUE HER:w
    #

  end
  it "lets us hit the Post table bound to the source database" do
    @fe_test_env.setup
    expect(Post.first).to be_a_kind_of(Post)
  end

  it "creates a source and target db on setup and deletes them on teardown" do
    @fe_test_env.setup
    expect(File.exist?(@fe_test_env.source_sqlite_database_file)).to eql(true)
    #expect(File.exist?(@fe_test_env.target_sqlite_database_file)).to eql(true)
  end

end
# This tests the test env. weird.
describe "FeTestEnv.instance properties" do
  it "has a root_path" do
    expect(FeTestEnv.instance.root_path).to match(/spec\/dummy_environments\/sqlite\/#{ENV['fe_test_env']}/)
    expect(File.directory?(FeTestEnv.instance.root_path)).to eql(true)
  end

  it 'has .model_files' do
    # TODO: CONTINUE HERE
    # expect(FeTestEnv.instance.model_files).to match(/post\.rb/)
    #
    pending
  end

  it 'has .model_classes' do
    pending
  end

  # WHAT ELSE CAN WE PORT FROM test/fe_test_env.rb
end

describe "FeTestEnv.instance.setup!" do
end
describe "FeTestEnv.instance.teardown!" do
end
describe "FeTestEnv.instance.reload!" do
end
