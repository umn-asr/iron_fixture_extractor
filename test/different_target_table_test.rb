# This test ensures that you can load_db into a different table/model
# than the one you extracted from
#
# THIS IS NOT COMPLETE, it seems like its impossible if you want to use
# ActiveRecord's .create_fixtures method...talk to Joe if you really
# need this feature
#
require 'test_helper'
class DfferentTargetTableTest < ActiveSupport::TestCase
  #setup do
    #@extract_code = 'Post.includes(:comments, :author).limit(1)'
    #@extract_name = :first_post_w_comments_and_authors
    #FeTestEnv.setup # regular production db
    #extract_hash = Fe.extract(@extract_code, :name => @extract_name)
    #FeTestEnv.the_env = 'fake_test'
    #FeTestEnv.recreate_schema_without_data
  #end
  #teardown do
    #FeTestEnv.teardown
  #end
  #should "provide the ability to load fixtures" do
    #assert_equal 0, Post.count
    #assert_equal 0, ::DifferentPost.count
    #assert_raise Fe::InvalidSourceModelToMapFrom do
      ## should fail cause User is not in the fixture set
      #extractor = Fe.load_db(@extract_name, User => Post)
    #end
    ## extractor = Fe.load_db(@extract_name, Post => ::DifferentPost)
    #require 'debugger'; debugger; puts 's'
    #puts "TODO: CONTINUE HERE WITH BUILDING THE CODE TO MAKE THE FOLLOWING 2 ASSERT STATEMENTS PASS"
    ##assert_equal 0, Post.count
    ##assert_equal 1, DifferentPost.count
    ##assert_equal 1, Author.count
  #end
end
