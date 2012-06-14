module Fe
  class Extractor
    attr_accessor :input_array, :extract_code, :name, :row_counts,:table_names
    def initialize(active_relation_or_array,*args)
      options = args.extract_options!
      @name = (options[:name] || Time.now.strftime("%Y_%m_%d_%H_%M_%S")).to_sym
      if active_relation_or_array.kind_of? String
        @extract_code = active_relation_or_array 
        @input_array = Array(eval(active_relation_or_array)).to_a
      else
        @extract_code = "load code not specified as string, you won't be able to reload this fixture from another database"
        @input_array = Array(active_relation_or_array).to_a
      end

      @row_counts = {}
      @table_names = {}
      self.output_hash.each_pair do |key,records|
        @row_counts[key] = records.length
        @table_names[key] = key.constantize.table_name
      end
    end
    def self.new_from_manifest(extract_name)
      h = YAML.load_file(File.join(Fe.fixtures_root,extract_name.to_s,'fe_manifest.yml'))
      t = self.new(h[:extract_code], :name => h[:name])
    end
    def write_fixtures
      FileUtils.rmdir(self.target_path)
      FileUtils.mkdir_p(self.target_path)
      File.open(self.manifest_file_path,'w') do |file|
        file.write( {:extract_code => self.extract_code,
                    :name => self.name,
                    :model_names => self.model_names,
                    :row_counts => self.row_counts,
                    :table_names => self.models.map {|m| m.table_name}
                    }.to_yaml)
      end
      self.write_model_fixtures
    end

    def load_into_database
      #manifest.mappings.each_pair do |key,hash|
        #ActiveRecord::Fixtures.create_fixtures(fixture_path_for_extract, hash['table_name'])
      #end

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
    def write_model_fixtures
      FileUtils.mkdir_p(self.target_path)
      self.output_hash.each_pair do |key,records|
        klass = key.constantize
        # key is an ActiveRecord class
        # records is an array of records to write
        File.open(File.join(self.target_path,"#{klass.table_name}.yml"),'w') do |file|
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
