require 'spec_helper'

describe "Fe.extract" do
  before(:each) do
    FeTestEnv.instance.bomb_and_rebuild
    @extract_code = 'Post.includes(:comments, :author).limit(1)'
    @extract_name = :first_post_w_comments_and_authors
  end

  it "should provide the right output, and put the file in the right place" do
    extractor = Fe.extract(@extract_code, :name => @extract_name)
    # CONTINUE HERE
    expect(extractor).to be_a_kind_of(Fe::Extractor)
    #assert (%w(Post Comment Author) - extractor.model_names).empty?, "only these keys should exist"
    #assert_equal @extract_name, extractor.name
    #assert_equal Post.table_name, extractor.table_names['Post']
    #assert File.exists?(File.join(Fe.fixtures_root,'first_post_w_comments_and_authors','fe_manifest.yml')), "The file that allows the fixtures to get rebuilt"
    #assert_equal 1, extractor.row_counts['Post']
    #assert_equal 1, extractor.row_counts['Author']
    #assert_kind_of Hash, extractor.manifest_hash
    #assert File.exists?(File.join(Fe.fixtures_root,'first_post_w_comments_and_authors',"#{Post.table_name}.yml")), "The file is created"
  end

end
