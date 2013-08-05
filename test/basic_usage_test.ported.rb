require 'test_helper'
class BasicUsage < ActiveSupport::TestCase
  context "Main API" do
    setup do
      @extract_code = 'Post.includes(:comments, :author).limit(1)'
      @extract_name = :first_post_w_comments_and_authors
    end
    context ".extract" do
      setup do
        FeTestEnv.setup
      end
      teardown do
        FeTestEnv.teardown
      end
      # PORTED
      #should "provide the right output, and put the file in the right place" do

        ## CONTINUE PORTING FROM HERE in extract_spec!!!!!!!!!!
        #extractor = Fe.extract(@extract_code, :name => @extract_name)
        #assert_kind_of Fe::Extractor, extractor
        #assert (%w(Post Comment Author) - extractor.model_names).empty?, "only these keys should exist"
        #assert_equal @extract_name, extractor.name
        #assert_equal Post.table_name, extractor.table_names['Post']
        #assert File.exists?(File.join(Fe.fixtures_root,'first_post_w_comments_and_authors','fe_manifest.yml')), "The file that allows the fixtures to get rebuilt"
        #assert_equal 1, extractor.row_counts['Post']
        #assert_equal 1, extractor.row_counts['Author']
        #assert_kind_of Hash, extractor.manifest_hash
        #assert File.exists?(File.join(Fe.fixtures_root,'first_post_w_comments_and_authors',"#{Post.table_name}.yml")), "The file is created"
      #end
    end
    context ".load_db, .execute_extract_code" do
      setup do
        FeTestEnv.setup # regular production db
        extract_hash = Fe.extract(@extract_code, :name => @extract_name)
        FeTestEnv.the_env = 'fake_test'
        FeTestEnv.recreate_schema_without_data
      end
      teardown do
        FeTestEnv.teardown
      end
      # PORTED
      #should "provide the ability to load fixtures" do
        #assert_equal 0, Post.count
        #assert_equal 0, Comment.count
        #assert_equal 0, Author.count
        #Fe.load_db(@extract_name)
        #assert_equal 1, Post.count
        #assert_equal 1, Comment.count
        #assert_equal 1, Author.count
      #end
      # PORTED
      #should "provide the ability to execute the same query that built the fixtures" do
        #Fe.load_db(@extract_name)
        #rows = Fe.execute_extract_code(:first_post_w_comments_and_authors)
        #assert_equal 1, rows.length
        #assert (rows.first.association_cache.keys - [:comments,:author]).empty?, "Comments and authors should be eager loaded"
      #end
    end
    context ".rebuild" do
      setup do
        FeTestEnv.setup
        @extractor = Fe.extract(@extract_code, :name => @extract_name)
      end
      teardown do
        FeTestEnv.teardown
      end
      # PORTED
      #should "be able to rebuild the fixture files from the manifest" do
        ## TODO: CONTINUE HERE JOE
        ## TODO: continue here, should delete a comment, then rebuild,
        ## and assert
        ##   all files mtimes have changed
        ##   there is no comment file
        #results = eval(@extract_code)
        #first_post = results.first
        #assert_match /First post/i, first_post.name
        #first_post.name = "UPDATED_FIRST_POST"
        #first_post.save!
        #rebuild_hash = Fe.rebuild(@extract_name)
        #assert_match /UPDATED_FIRST_POST/, File.read(@extractor.fixture_path_for_model('Post'))
        ##assert_equal 0, Post.count
      #end
    end

    context ".truncate_tables_for" do
      setup do
        FeTestEnv.setup # regular production db
        extract_hash = Fe.extract(@extract_code, :name => @extract_name)
        FeTestEnv.the_env = 'fake_test'
        FeTestEnv.recreate_schema_without_data
      end
      teardown do
        FeTestEnv.teardown
      end
      # PORTED
      #should "truncate only the tables in the fixture set" do
        #Group.create
        #assert_equal 1, Group.count

        #Fe.load_db(@extract_name)
        #assert_equal 1, Post.count
        #assert_equal 1, Comment.count
        #assert_equal 1, Author.count

        #Fe.truncate_tables_for(@extract_name)
        #assert_equal 1, Group.count
        #assert_equal 0, Post.count
        #assert_equal 0, Comment.count
        #assert_equal 0, Author.count

      #end
    end
  end
end
