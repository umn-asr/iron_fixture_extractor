require 'test_helper'
class GetHashTest < ActiveSupport::TestCase
  context "Fe" do
    setup do
      FeTestEnv.setup
      @extract_code = 'Post.includes(:comments, :author).limit(1)'
      @extract_name = :first_post_w_comments_and_authors
      extractor = Fe.extract(@extract_code, :name => @extract_name)
    end
    context ".extract" do
      should "have a .get_hash method" do
        assert_respond_to Fe, :get_hash
      end
      context ".get_hash behavior" do
        should "return a hash with the right columns" do
          h = Fe.get_hash(:first_post_w_comments_and_authors, Post, 'r1')
          assert_kind_of Hash, h
          assert_equal 1, h["id"]
          assert_equal "First post", h["name"]
          assert_equal "ComplexThing", h["serialized_thing"]
        end
      end
    end
    teardown do
      FeTestEnv.teardown
    end
  end
end
