require 'test_helper'
require 'factory_girl'
class FactoryGirlTest < ActiveSupport::TestCase
  setup do

    @extract_code = 'Post.includes(:comments, :author).limit(1)'
    @extract_name = :first_post_w_comments_and_authors
    FeTestEnv.setup # regular production db
    extract_hash = Fe.extract(@extract_code, :name => @extract_name)
    FeTestEnv.the_env = 'fake_test'
    FeTestEnv.recreate_schema_without_data

    @post_hash = Fe.get_hash(:first_post_w_comments_and_authors, Post,"r1")
    @instantiated_post_from_fe = Post.new(@post_hash)

    a_block = Proc.new {
      name "Block meta"
    }
    Fe.augment_factory_girl!
    FactoryGirl.define do
      factory :fe1, :class => Post
      factory :fe2, :class => Post, &a_block
      fe_factory :fe3, 
        :class => Post, 
        :extract_name => :first_post_w_comments_and_authors,
        :fixture_name => "r1"
    end
  end
  should "work" do
    assert_kind_of Hash, @post_hash

    assert_kind_of Post, @instantiated_post_from_fe
    assert @instantiated_post_from_fe.new_record?
    assert @instantiated_post_from_fe.new_record?

    @regular_created_factory = FactoryGirl.create(:fe1)
    assert_kind_of Post, @regular_created_factory

    @cheezy_way_fe_factory = FactoryGirl.create(:fe2)
    assert_equal "Block meta", @cheezy_way_fe_factory.name

    @fe_created_factory = FactoryGirl.create(:fe3)
    assert_kind_of Post, @fe_created_factory
  end
  teardown do
    FeTestEnv.teardown
  end
end
