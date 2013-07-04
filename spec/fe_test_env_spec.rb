require 'spec_helper'

describe "desired behavior" do
  before(:each) do
    @sqlite_env_path = File.join(File.dirname(__FILE__),'dummy_environments','sqlite','dummy1')
    @fe_test_env = FeTestEnv.new(@sqlite_env_path).initialize_tmp.load_models
  end

  it "lets us create data structures + data in source and switch to target with no problems",:focus => true do
    @fe_test_env.create_tables_in('source')
    expect(Post.first).to be_nil
    @fe_test_env.create_rows_in('source')
    expect(Post.first).to be_a_kind_of(Post)
    @fe_test_env.connect_to_target
    expect {Post.first}.to raise_exception
    @fe_test_env.create_tables_in('target')
    expect(Post.first).to be_nil
  end
end
describe "structure of a dummy environment" do
  before(:each) do
    @sqlite_env_path = File.join(File.dirname(__FILE__),'dummy_environments','sqlite','dummy1')
    @fe_test_env = FeTestEnv.new(@sqlite_env_path).initialize_tmp.load_models
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

  it "can connect to source and target" do
    # SOURCE
    @fe_test_env.connect_to_source
    source_db = @fe_test_env.database_dot_yml_hash['source']['database']
    expect(ActiveRecord::Base.connection).to be_a_kind_of(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
    ActiveRecord::Base.connection.execute('create table t (id int)')
    expect(ActiveRecord::Base.connection.tables.length).to eql(1)
    expect(File.exists?(source_db)).to eql(true)

    # TARGET
    #
    @fe_test_env.connect_to_target
    target_db = @fe_test_env.database_dot_yml_hash['target']['database']
    expect(ActiveRecord::Base.connection.instance_variable_get(:@config)[:database]).to eql(target_db)
    expect(ActiveRecord::Base.connection.tables.length).to eql(0)  # there is no table in target
    expect(File.exists?(target_db)).to eql(true)
  end
end

