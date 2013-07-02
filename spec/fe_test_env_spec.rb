require 'spec_helper'
# This tests the test env. weird.
describe "FeTestEnv.instance properties" do
  it "has a root_path" do
    expect(FeTestEnv.instance.root_path).to match(/spec\/dummy_environments\/#{ENV['fe_test_type']}\/#{ENV['fe_test_env']}/)
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
