require 'spec_helper'

describe "Single Table Inheritance extract and load behavior" do
  it "works as expected" do
    FeTestEnv.instance.bomb_and_rebuild
    @extract_code = 'User.where("1=1")'
    @extract_name = :all_users
    extractor = Fe.extract(@extract_code, :name => @extract_name)
    expect(extractor.models).to eql([User]), "This will correspond to one fixture file"
    FeTestEnv.instance.connect_to_target
    FeTestEnv.instance.create_tables_in('target')
    Fe.load_db(@extract_name)
    expect(User.all.map(&:type).sort).to eql(["User::Admin","User::Jerk"])
  end
end

