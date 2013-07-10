require 'test_helper'
class MultiTreeUsageTest < ActiveSupport::TestCase
  context "Multi Tree Usage" do
    setup do
      @extract_code = '[Post.includes(:comments).limit(1),Author.all]'
      @extract_name = :two_tree
    end
    context ".extract" do
      setup do
        FeTestEnv.setup
      end
      teardown do
#        FeTestEnv.teardown
      end
      should "provide the right output, and put the file in the right place" do
        extractor = Fe.extract(@extract_code, :name => @extract_name)
        assert (%w(Post Comment Author) - extractor.model_names).empty?, "only these keys should exist"
        assert File.exists?(File.join(Fe.fixtures_root,'two_tree','fe_manifest.yml')), "The file that allows the fixtures to get rebuilt"
        assert_equal 1, extractor.row_counts['Post']
        assert_equal 2, extractor.row_counts['Author']
        #assert File.exists?(File.join(Fe.fixtures_root,'first_post_w_comments_and_authors',"#{Post.table_name}.yml")), "The file is created"
      end
    end
  end
end
