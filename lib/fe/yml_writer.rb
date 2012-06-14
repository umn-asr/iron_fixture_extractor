module Fe
  class YmlWriter
    attr_reader :extractor
    def initialize(extractor)
      @extractor = extractor
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
      FileUtils.mkdir_p(self.extractor.target_path)
      self.extractor.output_hash.each_pair do |key,records|
        klass = key.constantize
        # key is an ActiveRecord class
        # records is an array of records to write
        File.open(File.join(self.extractor.target_path,"#{klass.table_name}.yml"),'w') do |file|
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
