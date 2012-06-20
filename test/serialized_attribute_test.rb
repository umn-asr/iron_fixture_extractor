require 'test_helper'
class SerializedAttributeTest < ActiveSupport::TestCase
  context "A model with a serialized attribute" do
    setup do
      @extract_code = 'Post.limit(1)'
      @extract_name = :posts_with_serialized_thing
    end
    context ".extract" do
      setup do
        FeTestEnv.setup
      end
      teardown do
        FeTestEnv.teardown
      end
      should "extract the .dump() value of the serialized attribute" do
        Fe.extract(@extract_code, :name => @extract_name)
        Fe.load_db(@extract_name)
        assert_nothing_raised do
          Post.first.serialized_thing
        end
      end
    end
  end
end
