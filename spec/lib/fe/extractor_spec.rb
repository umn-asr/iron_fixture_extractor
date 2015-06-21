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

  describe "build_from_manifest" do
    let(:extract_name)  { "test_extract" }
    let(:manifest_hash) { {test_manifest: "test", name: extract_name} }

    describe "when provdied a hash" do
      it "returns an instance of Fe:Extractor with the provided hash. " do
        built = Fe::Extractor.build_from_manifest(extract_name, manifest_hash)
        expect(built.name).to eq(extract_name)
        expect(built.manifest_hash).to eq(manifest_hash)
        expect(built).to be_a(Fe::Extractor)
      end

      #check git blame for more information on this test
      it "The name in the hash can override the provided name " do
        manifest_hash[:name] = "some_other_name"
        built = Fe::Extractor.build_from_manifest(extract_name, manifest_hash)
        expect(built.name).to eq("some_other_name")
      end
    end

    describe "when not provided a hash" do
      it "uses the content of a file to populate manifest_hash" do
        expect(YAML).to receive(:load_file).with(any_args).and_return(manifest_hash)
        built = Fe::Extractor.build_from_manifest(extract_name)
        expect(built.manifest_hash).to eq(manifest_hash)
      end
    end
  end
end
