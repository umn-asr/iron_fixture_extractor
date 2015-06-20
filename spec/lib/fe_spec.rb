require 'spec_helper'

describe Fe do
  let(:extractor_double) { Fe::Extractor.new }
  let(:extract_name) { 'test_extract' }
  let(:fact_name) { 'test_fact' }
  let(:fact_value) { rand }

  before do
    allow(Fe::Extractor).to receive(:build).with(extract_name).and_return(extractor_double)
  end

  describe "create_fact" do
    it "uses Extractor's fact setter" do
      extractor_double.should_receive(:add_fact).with(fact_name, fact_value).and_return(fact_value)
      returned = Fe.create_fact(extract_name, fact_name, fact_value)
      expect(returned).to eq(fact_value)
    end
  end

  describe "fact" do
    it "uses Extractor's fact getter" do
      extractor_double.should_receive(:fact).with(fact_name).and_return(fact_value)
      returned = Fe.fact(extract_name, fact_name)
      expect(returned).to eq(fact_value)
    end
  end
end
