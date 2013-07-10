require 'spec_helper'

describe "A model with a serialized attribute" do
  it "can .extract and .load_db correctly" do
    FeTestEnv.instance.bomb_and_rebuild
    @extract_code = 'Post.limit(1)'
    @extract_name = :posts_with_serialized_thing
    Fe.extract(@extract_code, :name => @extract_name)
    FeTestEnv.instance.connect_to_target
    FeTestEnv.instance.create_tables_in('target')
    Fe.load_db(@extract_name)
    if Post.count == 0
      raise "The test setup didn't work, Post.count should have some rows in the target"
    end
    expect(Post.first.serialized_thing).to be_a_kind_of(ComplexThing)
  end
end

