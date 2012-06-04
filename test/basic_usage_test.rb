require 'test_helper'
class BasicUsage < ActiveSupport::TestCase
  context "testing the test framework" do
    should "have rows for everything" do
      TestConfig.model_classes.each do |m|
        assert m.count > 0, "there is data in #{m}"
      end
    end
  end
  context "Top API" do
    should "respond to the following methods" do
      assert_respond_to Fe, :extract
    end
  end
  context "Simplest usage" do
    # Tests this usage
    #   # extract
    #   Fe.extract Post.first, :path => 'first_post'
    #   Wrote 1 Post row to test/tmp/fe_fixtures/first_post/post.yml
    #
    #   # load
    #   Fe.load(:first_post)
    setup do
      FileUtils.mkdir_p TestConfig.fixtures_root
      Fe.fixtures_root = TestConfig.fixtures_root
    end
    should "provide the right output, and put the file in the right place" do
      # CONTINUE HERE
      assert_match /Wrote/, Fe.extract(Post.first, :path => 'first_post')
      assert File.exists?('test/tmp/fe_fixtures/first_post/post.yml'), "The file is created"
    end
    teardown do
      # TODO: delete everything in fixtures folder
    end
  end
end
