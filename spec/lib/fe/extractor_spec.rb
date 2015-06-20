require 'spec_helper'

describe Fe::Extractor do
  describe "fact_hash" do
    let(:subject) do
      s = Fe::Extractor.new
      s.manifest_hash = {}
      s
    end

    describe "when the manifest has a fact hash" do
      let(:fact_hash) { {test_fact: 'test'} }

      before do
        subject.manifest_hash[:fact_hash] = fact_hash
      end

      it "returns the fact hash" do
        expect(subject.fact_hash).to eq(fact_hash)
      end
    end

    describe "when the manifest does not have a fact hash" do
      it "returns an empty hash" do
        expect(subject.fact_hash).to be_empty
        expect(subject.fact_hash).to respond_to(:keys)
      end
    end
  end

  describe "build" do
    it "returns an instance of Fe:Extractor with the extract name" do
      extract_name = "test_extract"
      built = Fe::Extractor.build(extract_name)
      expect(built.name).to eq(extract_name)
      expect(built).to be_a(Fe::Extractor)
    end
  end
end
