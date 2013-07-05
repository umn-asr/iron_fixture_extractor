require 'spec_helper'

describe "Fe.rebuild" do
  include FirstPostWCommentsAndAuthors

  # The following illustrates that the .yml file first does not have
  # BOOM_BOOM_TEST, then does after .rebuild
  it "rebuilds the fixture files from the manifest" do
    the_posts_fixture_file_contents = File.read(@extractor.fixture_path_for_model('Post'))
    first_post = Post.first
    expect(the_posts_fixture_file_contents).to include first_post.name
    expect(the_posts_fixture_file_contents).to_not include 'BOOM_BOOM_TEST'
    first_post.name = "BOOM_BOOM_TEST"
    first_post.save!
    Fe.rebuild(@extract_name)
    expect(File.read(@extractor.fixture_path_for_model('Post'))).to include 'BOOM_BOOM_TEST'
  end
end
