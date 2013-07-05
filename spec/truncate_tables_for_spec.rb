require 'spec_helper'

describe "Fe.truncate_tables_for(<extract_name>)" do
  include FirstPostWCommentsAndAuthors

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
  it "truncates only the tables in the fixture set" do
    FeTestEnv.instance.connect_to_target
    FeTestEnv.instance.create_tables_in('target')
    expect(Group.count).to eql(0)
    Group.create!
    expect(Group.count).to eql(1)
    Fe.load_db(@extract_name)
    expect(Group.count).to eql(1), "didn't load any groups in fixture set"
    @model_names.each do |mn|
      expect(mn.constantize.count).to be > 0
    end
    Fe.truncate_tables_for(@extract_name)
    @model_names.each do |mn|
      expect(mn.constantize.count).to eql(0)
    end
    expect(Group.count).to eql(1)
  end
end
