module FirstPostWCommentsAndAuthors
  extend ActiveSupport::Concern
  included do
    before(:each) do
      FeTestEnv.instance.bomb_and_rebuild
      @extract_code = 'Post.includes(:comments, :author).limit(1)'
      @extract_name = :first_post_w_comments_and_authors
      @extractor = Fe.extract(@extract_code, :name => @extract_name)
      @model_names = %w(Post Comment Author)
    end
  end
end
