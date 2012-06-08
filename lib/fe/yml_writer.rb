module Fe
  class YmlWriter
    attr_accessor :extractor, :name, :path,:fixture_file_stats
    def initialize(extractor, name, path)
      @extractor = extractor
      @name = name
      @path = path
      @fixture_file_stats = {}
    end
    def target_path
      File.join(self.path,self.name.to_s)
    end
    def counter
      if @counter.nil?
        @counter = "000000"
      else
        @counter.succ!
      end
      @counter
    end
    def write
      FileUtils.mkdir_p(self.target_path)
      self.extractor.output_hash.each_pair do |key,records|
        # key is an ActiveRecord class
        # records is an array of records to write
        File.open(File.join(self.target_path,"#{key.table_name.pluralize}.yml"),'w') do |file|
          # props to Rails Receipts 3rd edition book for these 4 lines
          # below
          file.write records.inject({}) {|hash, record|
            # Array() bit done to support composite primary keys
            fixture_name = "r#{Array(record.id).join('_')}"
            hash[fixture_name] = record.attributes
            hash
          }.to_yaml
        end
      end
    end
  end
end
