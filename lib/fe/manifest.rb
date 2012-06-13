module Fe
  class Manifest
    attr_accessor :yaml_hash
    def initialize(fixture_path_for_extract)
      self.yaml_hash = YAML.load_file(File.join(fixture_path_for_extract,'fe_manifest.yml'))
    end

    def mappings
      self.yaml_hash
    end
  end
end
