require 'test_helper'
require 'factory_girl'
class FactoryGirlTest < ActiveSupport::TestCase
  setup do

    @extract_code = 'Post.includes(:comments, :author).limit(1)'
    @extract_name = :first_post_w_comments_and_authors
    FeTestEnv.setup # regular production db
    Fe.extract(@extract_code, :name => @extract_name) # build fixture yml
    FeTestEnv.the_env = 'fake_test'
    FeTestEnv.recreate_schema_without_data

    @post_hash = Fe.get_hash(:first_post_w_comments_and_authors, Post,"r1")


  end
  should "expose a .to_factory_girl_string method" do
    assert_kind_of Hash, @post_hash
    assert_respond_to @post_hash, :to_factory_girl_string
    assert !Hash.instance_methods.include?(:to_factory_girl_string)

    @fg_string = @post_hash.to_factory_girl_string
    assert_match /Post/, @fg_string, "The string should have the model name on the first line"
  end

  should ".to_factory_girl_string should return a monkey patched string implementing .to_proc" do
    @fg_string = @post_hash.to_factory_girl_string
    assert_respond_to @fg_string, :to_proc
    puts @fg_string
  end

  should "be just like a factory produced in a non-meta way" do
    FactoryGirl.define do
      # This is the essense of the code that .to_factory_girl_string spits out
      factory :fe2, :class => Post do
        x = Post.new(Fe.get_hash(:first_post_w_comments_and_authors,Post,"r1"))
        id x.id
        author_id x.author_id
        name x.name
        content x.content
        serialized_thing x.serialized_thing
        created_at x.created_at
        updated_at x.updated_at
      end

      # We are evaluating the to_factory_girl_string in the block context factory girl
      # if you wanted to override settings you could do so afterwords
      factory :fe3, :class => Post, &Proc.new {
        self.instance_eval(Fe.get_hash(:first_post_w_comments_and_authors,Post,"r1").to_factory_girl_string)
        # I think You could override attributes set in the fixture here, like:
        # name "poo poo"
      }

      # This is two levels meta-ness away
      factory :fe4,
        :class => Post,
        &Fe.get_hash(:first_post_w_comments_and_authors,Post,"r1").to_factory_girl_string.to_proc
    end

    @fe2 = FactoryGirl.create(:fe2)
    assert_kind_of Post, @fe2

    @fe3 = FactoryGirl.create(:fe3)
    assert_kind_of Post, @fe3
    assert_kind_of Time, @fe3.updated_at, "Objects get the right type"

    @fe4 = FactoryGirl.create(:fe4)
    assert_kind_of Post, @fe4
    assert_kind_of Time, @fe4.updated_at, "Objects get the right type"
  end
  teardown do
    FeTestEnv.teardown
  end
end
