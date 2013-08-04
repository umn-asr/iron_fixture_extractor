require 'spec_helper'

describe "Fe.load_db" do
  include FirstPostWCommentsAndAuthors
  it "ensures the test env is all good..there are no rows" do
    FeTestEnv.instance.connect_to_target
    FeTestEnv.instance.create_tables_in('target')
    @model_names.each do |mn|
      expect(mn.constantize.count).to eql(0)
    end   
  end
  it "has a loaded target database with the same number of rows than is in the source" do
    FeTestEnv.instance.connect_to_target
    FeTestEnv.instance.create_tables_in('target')
    Fe.load_db(@extract_name)
    @extractor.row_counts.each_pair do |m,c|
      expect(m.constantize.count).to eql(c), "number of rows in the target should be the same as the counts from the source given the extract_code"
    end
  end
  context ":only and :except options" do
    before(:each) do
      FeTestEnv.instance.connect_to_target
      FeTestEnv.instance.create_tables_in('target')
    end
    it "supports :only => Array of yml file names to only load particular tables" do
      expect {
        Fe.load_db(@extract_name, :only => 'posts' )
      }.to change {
        Post.count
      }.from(0).to(1)
      expect(Author.count).to eql(0)
      expect(Comment.count).to eql(0)
    end

    it "supports :except => Array of yml file names to load all tables except those specified" do
      extractor = Fe.load_db(@extract_name, :except => ['authors', 'comments'] )
      expect(Author.count).to eql(0)
      expect(Comment.count).to eql(0)
      expect(Post.count).to eql(extractor.row_counts['Post'])
    end

    it "raises an exception no models result after the :only or :except filters" do
      expect {
        Fe.load_db(@extract_name, :except => ['authors', 'comments','posts'] )
      }.to raise_exception
    end
  end
end
