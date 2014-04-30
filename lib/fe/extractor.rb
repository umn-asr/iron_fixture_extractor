module Fe
  class Extractor
    attr_accessor :input_array,
      :extract_code,
      :name,
      :row_counts,
      :table_names,
      :table_name_to_model_name_hash,
      :manifest_hash

    ##################
    #   PUBLIC API   #
    ##################
    #

    def initialize
      # This delays the constraint checked to the end of the transaction allowing inserting rows out of order when tables have foreign key to each other. 
      # Solves also teh issue with truncating when foreign keys are present. 
      # TODO: adapt this to other databases if needed 
      ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL DEFERRED") if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
    end

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
                        :table_names => self.models.map {|m| m.table_name},
                        :table_name_to_model_name_hash => self.models.inject({}) {|h,m| h[m.table_name] = m.to_s; h }
                       }
      File.open(self.manifest_file_path,'w') do |file|
        file.write(@manifest_hash.to_yaml)
      end
      self.write_model_fixtures
    end

    # Loads data from each fixture file in the extract set using
    # ActiveRecord::Fixtures
    #
    def load_into_database(options={})
      # necessary to make multiple invocations possible in a single test
      # case possible
      ActiveRecord::Fixtures.reset_cache

      # Filter down the models to load if specified
      the_tables = if options.has_key?(:only)
        self.table_names.select {|x| Array(options[:only]).map(&:to_s).include?(x) }
      elsif options.has_key?(:except)
        self.table_names.select {|x| !Array(options[:except]).map(&:to_s).include?(x) }
      else
        self.table_names
      end
      raise "No models to load, relax your :only or :except filters (or don't bother calling this method)" if the_tables.empty?


      #This wraps all the inserts into a single transaction allowing the constraint check to happen at the end.
      ActiveRecord::Base.transaction do

        the_tables.each do |table_name|
          class_name = if self.table_name_to_model_name_hash.kind_of?(Hash)
            self.table_name_to_model_name_hash[table_name]
          else
            ActiveSupport::Deprecation.warn "your fe_manifest.yml does not contain a table_name_to_model_name_hash (as found in 1.0.0 or earlier). Version 2.0.0 will require this. See test cases for how to manually jigger your fe_manifest.ymls to function."
            nil
          end
          if options[:map].nil?
            # Vanilla create_fixtures will work fine when no mapping is being used
            ActiveRecord::Fixtures.create_fixtures(self.target_path, table_name)
          else
            # Map table_name via a function (great for prefixing)
            new_table_name = if options[:map].kind_of?(Proc)
              options[:map].call(table_name)
            # Map table_name via a Hash table name mapping
            elsif options[:map][table_name].kind_of? String
              options[:map][table_name]
            else
              table_name # No mapping for this table name
            end
            fixtures = ActiveRecord::Fixtures.new( ActiveRecord::Base.connection,
                new_table_name,
                class_name,
                ::File.join(self.target_path, table_name))
            fixtures.table_rows.each do |the_table_name,rows|
              rows.each do |row|
                ActiveRecord::Base.connection.insert_fixture(row, the_table_name)
              end
            end
          end
          # FIXME: The right way to do this is to fork the oracle enhanced adapter
          # and implement a reset_pk_sequence! method, this is what ActiveRecord::Fixtures
          # calls.  aka this code should be eliminated/live elsewhere.
          case ActiveRecord::Base.connection.adapter_name
          when /oracle/i
            model = class_name.constantize
            if model.column_names.include? "id"
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
      end # End transaction
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
      @row_counts = @manifest_hash[:row_counts]
      @table_names = @manifest_hash[:table_names]
      @table_name_to_model_name_hash = @manifest_hash[:table_name_to_model_name_hash]
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
      return if @output_hash[key].include?(record) # Prevent infinite loops as association cache on record with inverse_of will cause this method to stack overflow
      @output_hash[key].add(record)
      record.association_cache.each_pair do |assoc_name,association_def|
        Array(association_def.target).each do |a|
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
