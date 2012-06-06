module Fe
  class Extractor
    attr_accessor :extract_code, :input_array
    # Returns a hash with model class names for keys and Set's of AR
    # instances for values
    def output_hash
      if @output_hash.blank?
        @output_hash = {}
        self.input_array.each do |t|
          recurse(t)
        end
      end
      @output_hash
    end
    protected
    def recurse(record)
      debugger
      raise "This gem only knows how to extract stuff w ActiveRecord" unless record.kind_of? ActiveRecord::Base
      @output_hash[record.class] ||= Set.new # Set ensures no duplicates
      @output_hash[record.class].add record 
      record.association_cache.each do |assoc_cache|
        assoc_name = assoc_cache.first
        assoc_value = assoc_cache.last.target
        unless assoc_value.kind_of? Array
          assoc_value = Array(assoc_value)
        end
        assoc_value.each do |a|
          self.recurse(a)
        end
      end
    end
  end
end
