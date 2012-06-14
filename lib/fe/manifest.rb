module Fe
  class Manifest
    attr_accessor :yaml_hash, :extractor
    def initialize(extractor)
      @extractor = extractor
    end
    #def load
      #self.yaml_hash = YAML.load_file(self.file_path)
      #%w(mappings extract_code).each do |k|
        #raise "invalid yaml format, does not contain #{k} hash key" if self.yaml_hash[k].blank?
        #self.send(:"#{k}=", self.yaml_hash[k])
      #end
    #end
    def write
      File.open(self.file_path,'w') do |file|
        file.write({'model_names' => @extractor.model_names, 'extract_code' => @extractor.extract_code}.to_yaml)
      end
    end
        # TODO: move this to Manifest, it should be responsible for
        # writing and reading from the manifest
        #File.open(File.join(self.target_path,"fe_manifest.yml"),'w') do |file|
          #file.write self.stats_hash.to_yaml
        #end
  end
end
