require 'test_helper'
class SerializedAttributeTest < ActiveSupport::TestCase
  context "A model with a serialized attribute" do
    setup do
      @extract_code = 'Post.limit(1)'
      @extract_name = :posts_with_serialized_thing
    end
    context ".extract and .load_db with serialized attributes" do
      setup do
        FeTestEnv.setup
        Fe.extract(@extract_code, :name => @extract_name)
        FeTestEnv.the_env = 'fake_test'
        FeTestEnv.recreate_schema_without_data
      end
      teardown do
        FeTestEnv.teardown
      end
      should "extract the .dump() value of the serialized attribute" do
        Fe.load_db(@extract_name)
        if Post.count == 0
          raise "The test setup didn't work, Post.count should have some rows"
        end
        assert_kind_of ComplexThing, Post.first.serialized_thing
      end
    end
  end
end
