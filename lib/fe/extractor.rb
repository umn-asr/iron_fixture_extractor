module Fe
  class Extractor
    attr_reader :input_array, :extract_code, :name, :manifest,:fixture_writer,:row_counts,:table_names
    def initialize(active_relation_or_array,*args)
      options = args.extract_options!
      @name = (options[:name] || Time.now.strftime("%Y_%m_%d_%H_%M_%S")).to_sym
      @manifest = Fe::Manifest.new(self)
      @fixture_writer = Fe::YmlWriter.new(self)
      set_extract_code_and_input_array(active_relation_or_array)
      @row_counts = {}
      @table_names = {}
      self.output_hash.each_pair do |key,records|
        @row_counts[key] = records.length
        @table_names[key] = key.constantize.table_name
      end
    end
    def write_fixtures
      self.fixture_writer.write
      self.manifest
      File.open(self.manifest_file_path,'w') do |file|
        file.write( {:extract_code => self.extract_code,
                    :name => self.name,
                    :model_names => self.model_names,
                    :row_counts => self.row_counts,
                    :table_names => self.models.map {|m| m.table_name}
                    }.to_yaml)
      end
    end
    # Returns a hash with model class names for keys and Set's of AR
    # instances for values
    # aka like this
    #   {'Post' => [<#Post id:1>,<#Post id:2>],
    #    'Comment' => [<#Comment id:1>,<#Comment id:2>]}
    #
    def output_hash
      if @output_hash.blank?
        @output_hash = {}
        self.input_array.each do |t|
          recurse(t)
        end
      end
      @output_hash
    end

    def model_names
      self.output_hash.keys
    end
    def models
      self.model_names.map {|x| x.constantize}
    end

    def target_path
      File.join(Fe.fixtures_root,self.name.to_s)
    end

    def manifest_file_path
      File.join(self.target_path,'fe_manifest.yml')
    end
    protected


    def set_extract_code_and_input_array(active_relation_or_array)
      if active_relation_or_array.kind_of? String
        @extract_code = active_relation_or_array 
        @input_array = Array(eval(active_relation_or_array)).to_a
      else
        @extract_code = "load code not specified as string, you won't be able to reload this fixture from another database"
        @input_array = Array(active_relation_or_array).to_a
      end
    end
    # Recursively goes over all association_cache's from the record and builds the output_hash
    def recurse(record)
      raise "This gem only knows how to extract stuff w ActiveRecord" unless record.kind_of? ActiveRecord::Base
      @output_hash[record.class.to_s] ||= Set.new # Set ensures no duplicates
      @output_hash[record.class.to_s].add record 
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
