require 'test_helper'
class GetHashTest < ActiveSupport::TestCase
  context "Fe#get_hash" do
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

          # allow :first to grab the first fixture, so you don't have to know the name
          h2 = Fe.get_hash(:first_post_w_comments_and_authors, Post, :first)
          assert_equal h, h2

          h3 = Fe.get_hash(:first_post_w_comments_and_authors, Post, :last)
          assert_equal h, h3, "there is only one fixture in this set to last is the same as first"
        end
      end
    end
    teardown do
      FeTestEnv.teardown
    end
  end
  context "Fe#get_hashes" do
    setup do
      FeTestEnv.setup
      @extract_code = 'Post.all'
      @extract_name = :all_posts
      extractor = Fe.extract(@extract_code, :name => @extract_name)
    end
    should "work as expected...(this might fail on 1.8.7, where hashes aren't ordered)" do
      uber_fixture_hash = Fe.get_hash(:all_posts, Post, :all)
      fixture_hashes = Fe.get_hashes(:all_posts, Post)
      assert_equal(uber_fixture_hash.values, fixture_hashes, "get_hashes is syntactic sugar for get_hash(...).values")
    end
    teardown do
      FeTestEnv.teardown
    end
  end
end
