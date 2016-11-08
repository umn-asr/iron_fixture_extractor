require 'spec_helper'

describe "Fe.execute_extract_code" do
  include FirstPostWCommentsAndAuthors
  it "provides the ability to execute the same query that built the fixtures" do
    FeTestEnv.instance.connect_to_target
    FeTestEnv.instance.create_tables_in('target')
    Fe.load_db(@extract_name)
    rows = Fe.execute_extract_code(@extract_name)
    expect(rows.length).to eql(@extractor.row_counts['Post'])
    expect(loaded_association_names(rows.first) - [:comments,:author]).to be_empty, "Comments and authors should be eager loaded"
  end

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

  def loaded_association_names(record)
    record.class.reflect_on_all_associations.select do |reflection|
      record.association(reflection.name).loaded?
    end.map(&:name)
  end
end
