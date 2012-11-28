require 'test_helper'
class DfferentTargetTableTest < ActiveSupport::TestCase
  setup do
    @extract_code = 'Post.includes(:comments, :author).limit(1)'
    @extract_name = :first_post_w_comments_and_authors
    FeTestEnv.setup # regular production db
    extract_hash = Fe.extract(@extract_code, :name => @extract_name)
    FeTestEnv.the_env = 'fake_test'
    FeTestEnv.recreate_schema_without_data
  end
  teardown do
    FeTestEnv.teardown
  end
  should "provide the ability to load fixtures" do
    assert_equal 0, Post.count
    assert_equal 0, ::DifferentPost.count
    Fe.load_db(@extract_name)

    puts "TODO: CONTINUE HERE WITH BUILDING THE CODE TO MAKE THE FOLLOWING 2 ASSERT STATEMENTS PASS"
    #assert_equal 0, Post.count
    #assert_equal 1, DifferentPost.count
    #assert_equal 1, Author.count
  end
end
