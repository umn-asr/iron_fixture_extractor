# TODO: PORT
# class MultiTreeUsageTest < ActiveSupport::TestCase

require 'spec_helper'

describe "Fe.extract('[Post.includes(:comments).limit(1),Author.all]', :name => :two_tree) style usage works" do
  it "provides the right output and puts files in the right place" do
    @extract_code = '[Post.includes(:comments).limit(1),Author.all]'
    @extract_name = :two_tree
    extractor = Fe.extract(@extract_code, :name => @extract_name)
    expect(%w(Post Comment Author) - extractor.model_names).to be_empty
    expect(File.exists?(File.join(Fe.fixtures_root,'two_tree','fe_manifest.yml'))).to eql(true)
    expect(extractor.row_counts['Post']).to eql(1)
  end
end
