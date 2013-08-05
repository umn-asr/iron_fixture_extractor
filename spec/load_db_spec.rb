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

  context ":map option" do
    # TODO: This is sloppy...and should probably live elsewhere
    it "should expose a table_name_to_model_name hash", :focus => true do
      extractor = Fe.load_db(@extract_name)
      expect(extractor.table_name_to_model_name_hash).to be_a_kind_of(Hash)
    end

    #before(:each) do
      #FeTestEnv.instance.connect_to_target
      #FeTestEnv.instance.create_tables_in('target')
      #Post.connection.execute("ALTER TABLE posts RENAME TO foo_posts")
      #Post.table_name = 'foo_posts'
    #end

    # Two uses
    #
    #   1) Load into a different table but the same model
    #
    #     :map => {:posts => :foo_posts}
    #
    #   2) Load into a different model
    #
    #     :map => {Post => FooPost}
    #
    #   3) Or for a prefix style map
    #
    #     :map => -> 
    #
    # Assumptions
    # The same model exists in both the source and the target, but the underlying table
    # name is different
    #it "should fail without a :map option" do
      #expect(Post.table_name).to eql('foo_posts'), "testing the test setup"
      #expect {
        #Fe.load_db(@extract_name)
      #}.to raise_exception
    #end

    #it "should work with the right map option specified", :focus => true do
      #expect {
        #Fe.load_db(@extract_name,
                   #:map => -> source_table { "foo_#{source_table}" },
                   #:only => 'posts'
                  #)
      #}.to_not raise_exception
    #end
  end
end
