require 'spec_helper'

describe "Fe.load_db(..., :map)" do
  before(:each) do
    FeTestEnv.instance.bomb_and_rebuild
    Fe.extract("Post.where('1=1')", :name => :all_posts)
    FeTestEnv.instance.connect_to_target
    FeTestEnv.instance.create_tables_in('target')
  end

  it "should allow you to load into a different table via Hash mapping" do
    expect {
      Fe.load_db(:all_posts, :map => {'posts' => 'different_posts'})
    }.to change {
      DifferentPost.count
    }.from(0)
    expect(Post.count).to eql(0)
  end

  it "should allow you to load into a different table via Proc mapping" do
    expect {
      Fe.load_db(:all_posts, :map => -> table_name { "different_#{table_name}" })
    }.to change {
      DifferentPost.count
    }.from(0)
    expect(Post.count).to eql(0)
  end

  it "should allow you to load into a different table but same model" do
    begin
      Post.connection.execute("ALTER TABLE posts RENAME TO foo_posts")
      Post.table_name = 'foo_posts'
      Fe.load_db(:all_posts, :map => -> table_name { "foo_#{table_name}" })
      expect(Post.count).to be > 0
    ensure
      Post.table_name = 'posts'
    end
  end
end
