# 
module Fe
  class Extractor
    attr_accessor :input_array, :extract_code, :name, :row_counts,:table_names, :manifest_hash

    ##################
    #   PUBLIC API   #
    ##################
    #
    def extract
      load_input_array_by_executing_extract_code
      @row_counts = {}
      @table_names = {}
      self.output_hash.each_pair do |key,records|
        @row_counts[key] = records.length
        @table_names[key] = key.constantize.table_name
      end

      if File.directory?(self.target_path)
        FileUtils.remove_dir(self.target_path,:force => true)
      end
      FileUtils.mkdir_p(self.target_path)
      @manifest_hash = {:extract_code => self.extract_code,
                        :name => self.name,
                        :model_names => self.model_names,
                        :row_counts => self.row_counts,
                        :table_names => self.models.map {|m| m.table_name}
                       }
      File.open(self.manifest_file_path,'w') do |file|
        file.write(@manifest_hash.to_yaml)
      end
      self.write_model_fixtures
    end

    # Loads data from each fixture file in the extract set using
    # ActiveRecord::Fixtures
    #
    def load_into_database
      # necessary to make multiple invocations possible in a single test
      # case possible
      ActiveRecord::Fixtures.reset_cache
      self.models.each do |model|
        if self.map_models_hash.has_key?(model)
          raise "Unfortunately, this is not implemented...from the implementation of .create_fixtures it seems impossible...keeping this code in case its not"
          h = {model.table_name => self.map_models_hash[model]}
          ActiveRecord::Fixtures.create_fixtures(self.target_path, model.table_name, h)
        else
          ActiveRecord::Fixtures.create_fixtures(self.target_path, model.table_name)
        end
        case ActiveRecord::Base.connection.adapter_name
        when /oracle/i
          if model.column_names.include? "id"
            count = model.count
            sequence_name = model.sequence_name.to_s
            max_id = model.maximum(:id)
            next_id = max_id.nil? ? 1 : max_id.to_i + 1
            begin
              ActiveRecord::Base.connection.execute("drop sequence #{sequence_name}")
            rescue
              puts "[Iron Fixture Extractor] WARNING: couldnt drop the sequence #{sequence_name}, (but who cares!)"
            end
            begin
              q="create sequence #{sequence_name} increment by 1 start with #{next_id}"
              ActiveRecord::Base.connection.execute(q)
            rescue
              puts "[Iron Fixture Extractor] WARNING: couldnt create the sequence #{sequence_name}"
            end
          end
        else
          # Do nothing, only oracle adapters need this
        end
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
          if t.kind_of?(Array) || t.kind_of?(ActiveRecord::Relation)
            t.each do |ar_object|
              recurse(ar_object)
            end
          else
            recurse(t)
          end
        end
      end
      @output_hash
    end

    def model_names
      self.output_hash.keys
    end

    # Note: this behavior is different if load_from_manifest vs
    # load_from_args
    def models
      @models ||= self.model_names.map {|x| x.constantize}
    end

    def target_path
      File.join(Fe.fixtures_root,self.name.to_s)
    end

    def manifest_file_path
      File.join(self.target_path,'fe_manifest.yml')
    end

    def fixture_path_for_model(model_name)
      File.join(self.target_path,"#{model_name.constantize.table_name}.yml")
    end

    def fixture_hash_for_model(model_name)
      model_name = model_name.to_s
      if @fixture_hashes.nil?
        @fixture_hashes = {}
      end
      if @fixture_hashes.has_key?(model_name) 
        @fixture_hashes[model_name]
      else
        @fixture_hashes[model_name] = YAML.load_file(self.fixture_path_for_model(model_name))
      end
      @fixture_hashes[model_name]
    end


    #############################
    #   OVERLOADED CONSTRUCTORS #
    #############################
    #
    # * These are used by the Fe module to setup the Extractor object
    # This is called from 2 types of invocations
    #   Fe.extract('Post.all', :name => :bla)
    #   or 
    #   Fe.extract('[Post.all,Comment.all]', :name => :bla2)
    #   
    def load_from_args(active_relation_or_array,*args)
      options = args.extract_options!
      @name = (options[:name] || Time.now.strftime("%Y_%m_%d_%H_%M_%S")).to_sym
      if active_relation_or_array.kind_of? String
        @extract_code = active_relation_or_array 
      else
        raise "Extract code must be a string, so .rebuild can be called"
      end
    end

    def load_input_array_by_executing_extract_code
      @input_array = Array(eval(@extract_code)).to_a
    end

    def load_from_manifest
      raise "u gotta set .name to use this method" if self.name.blank?
      @manifest_hash = YAML.load_file(self.manifest_file_path)
      @extract_code = @manifest_hash[:extract_code]
      @name = @manifest_hash[:name]
      @models = @manifest_hash[:model_names].map {|x| x.constantize}
    end

    # TODO: WHAT IS THIS? DEPRECATE?
    # I think it was used for when you want to load the fixtures into new table names in the target
    # that are different from the source, but wasn't quite finished
    def map_models_hash=(map_models_hash)
      unless (map_models_hash.keys - self.models).empty?
        raise InvalidSourceModelToMapFrom.new "your map models hash must contain keys representing class names that exist in the fe_manifest.yml"
      end
      @map_models_hash = map_models_hash
    end

    def map_models_hash
      if @map_models_hash.nil?
        {}
      else
        @map_models_hash
      end
    end

    protected

    # Recursively goes over all association_cache's from the record and builds the output_hash
    # This is the meat-and-potatoes of this tool (plus the the recurse
    # method) is where something interesting is happening
    #
    def recurse(record)
      raise "This gem only knows how to extract stuff w ActiveRecord" unless record.kind_of? ActiveRecord::Base
      key = record.class.base_class.to_s # the base_class is key for correctly handling STI
      @output_hash[key] ||= Set.new # Set ensures no duplicates
      @output_hash[key].add record
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
        # key is an ActiveRecord class
        # records is an array of records to write
        File.open(self.fixture_path_for_model(key),'w') do |file|
          # props to Rails Receipts 3rd edition book for these 4 lines
          # below
          file.write records.inject({}) {|hash, record|
            # Array() bit done to support composite primary keys
            fixture_name = "r#{Array(record.id).join('_')}"
            hash[fixture_name] = record.attributes
            # dump serialized attributes
            record.serialized_attributes.each do |attr, serializer|
              hash[fixture_name][attr] = serializer.dump(hash[fixture_name][attr])
            end
            hash
          }.to_yaml
        end
      end
    end
  end
end
