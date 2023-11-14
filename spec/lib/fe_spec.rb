require 'spec_helper'

describe Fe do
  let(:extractor_class_double) { class_double("Fe::Extractor").as_stubbed_const }
  let(:extractor_double) { instance_double("Fe::Extractor") }
  let(:extract_name) { 'test_extract' }
  let(:fact_name) { 'test_fact' }
  let(:fact_value) { rand }

  before do
    allow(extractor_class_double).to receive(:build_from_manifest).with(extract_name).and_return(extractor_double)
  end

  describe "create_fact" do
    it "uses Extractor's fact setter" do
      expect(extractor_double).to receive(:add_fact).with(fact_name, fact_value).and_return(fact_value)
      returned = Fe.create_fact(extract_name, fact_name, fact_value)
      expect(returned).to eq(fact_value)
    end
  end

  describe "fact" do
    it "uses Extractor's fact getter" do
      expect(extractor_double).to receive(:fact).with(fact_name).and_return(fact_value)
      returned = Fe.fact(extract_name, fact_name)
      expect(returned).to eq(fact_value)
    end
  end
end
