require 'test_helper'
class StiTest < ActiveSupport::TestCase
  setup do
    FeTestEnv.setup
    @extract_code = 'User.where("1=1")'
    @extract_name = :all_users
  end
  teardown do
    FeTestEnv.teardown
  end
  should "yo" do
    extractor = Fe.extract(@extract_code, :name => @extract_name)
    assert_equal [User], extractor.models
    assert_equal({'User' => 2}, extractor.row_counts)
    FeTestEnv.the_env = 'fake_test'
    FeTestEnv.recreate_schema_without_data
    Fe.load_db(@extract_name)
    assert_equal ["User::Admin", "User::Jerk"], User.all.map(&:type).sort
  end
end
