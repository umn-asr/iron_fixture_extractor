require 'spec_helper'

describe "Fe.extract and Fe::Extractor instances" do
  include FirstPostWCommentsAndAuthors
  it "should return an Fe::Extractor instance that exposes the extracted data information" do
    expect(@extractor).to be_a_kind_of(Fe::Extractor)

    # The stuff passed into the constructor
    expect(@extract_name.to_sym).to eql(@extractor.name), "note that the extractor name is a symbol, even if given a string"
    expect(@extract_code).to eql(@extractor.extract_code), "the code used to pull the data"

    # The models involved
    expect(@extractor.model_names - @model_names).to be_empty
    expect(@extractor.models).to be_a_kind_of(Array)
    expect(@extractor.models.first.ancestors).to include(ActiveRecord::Base)

    # The fixture files involved
    expect(@extractor.manifest_hash).to be_a_kind_of(Hash), "The hash representation of what is saved to fe_manifest.yml"
    expect(@extractor.output_hash).to be_a_kind_of(Hash), "The hash representation all of the the extracted data"
    @model_names.each do |mn|
      @extractor.output_hash.keys
    end 
  end
  it "should put data into the .yml files" do
    expect(Post.table_name).to eql(@extractor.table_names['Post'])
    expect(File.exist?(File.join(Fe.fixtures_root,'first_post_w_comments_and_authors','fe_manifest.yml'))).to eql(true)
    @model_names.each do |mn|
      expect(File.exist?(File.join(Fe.fixtures_root,'first_post_w_comments_and_authors',"#{mn.constantize.table_name}.yml"))).to eql(true)
    end

    # Asserting the state of the imported data--tied to the data_migrations
    # brittle
    expect(@extractor.row_counts['Post']).to eql(1)
    expect(@extractor.row_counts['Author']).to eql(1)
  end

end
