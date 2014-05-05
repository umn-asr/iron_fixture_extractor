# NOTE: require 'iron_fixture_extractor', NOT this file
module Fe
  class InvalidSourceModelToMapFrom < Exception; end
  extend ActiveSupport::Autoload
  autoload :Extractor
  require 'fe/railtie' if defined?(Rails)

  # global configuration
   
  @@fixtures_root = 'test/fe_fixtures'
  mattr_accessor :fixtures_root

  # Top-level API methods
  class << self
    # Extract a set up Yml for one or more active relation alls
    # You can call this in two ways
    #   Fe.extract('Post.all', :name => :bla)
    #   or 
    #   Fe.extract('[Post.all,Comment.all]', :name => :bla2)
    #
    def extract(*args)
      extractor = Fe::Extractor.new
      extractor.load_from_args(*args)
      extractor.extract
      extractor
    end

    # Insert fixtures into tables from the yml files in the
    # "extract_name" fixture set
    # NOTE: This is destructive, it will delete everything in the target table
    #
    def load_db(extract_name, options={})
      extractor = Fe::Extractor.new
      extractor.name = extract_name
      extractor.load_from_manifest
      extractor.load_into_database(options)
      extractor
    end

    # Rebuilds an existing fixture set from a fe_manifest.yml
    #
    def rebuild(extract_name)
      extractor = Fe::Extractor.new
      extractor.name = extract_name
      extractor.load_from_manifest
      extractor.extract
      extractor
    end


    # Used if you want to get a hash representation of a particular
    # fixture in a fixture set for a given model
    #
    # Used like:
    #
    #   h = Fe.get_hash(:first_post_w_comments_and_authors, Post, :first)
    #
    #   # => {:id => 1, :name => 'first post', ....}
    #
    # in the console
    #
    def get_hash(extract_name, model_name, fixture_name)
      model_name = model_name.to_s 
      extractor = Fe::Extractor.new
      extractor.name = extract_name

      begin
        h=extractor.fixture_hash_for_model(model_name)
      rescue Exception => e
        raise "Fe::Extractor#fixture_hash_for_model broke on #{model_name}, perhaps the yml file does exist?"
      end
      raise "#{h.inspect} Fe::Extractor#fixture_hash_for_model did not return a hash (broken fixture file)" unless h.kind_of? Hash

      fixture_path_for_model = extractor.fixture_path_for_model(model_name)

      if fixture_name.kind_of? Symbol
        case fixture_name
        when :first
          a_hash = h.to_a.first.last
        when :last
          a_hash = h.to_a.last.last
        when :all
          a_hash = h
        else
          raise "symbols can be :first, :last, or :all"
        end
      elsif fixture_name.kind_of? String
        raise "Fixture of the name #{fixture_name} did not exist in in #{fixture_path_for_model}" unless h.has_key?(fixture_name)
        a_hash = h[fixture_name]
      else
        raise "fixture name must be a string or a symbol"
      end
      a_hash
    end


    # Syntactic sugar for get_hash(extract_name, model_name, :all).values
    #
    def get_hashes(extract_name, model_name)
      self.get_hash(extract_name, model_name, :all).values
    end

    # Execute the ActiveRecord query associated with the extract set
    #
    def execute_extract_code(extract_name)
      extractor = Fe::Extractor.new
      extractor.name = extract_name
      extractor.load_from_manifest
      extractor.load_input_array_by_executing_extract_code
      extractor.input_array
    end


    # Truncate all tables referenced in an extract set
    #
    def truncate_tables_for(extract_name)
      extractor = Fe::Extractor.new
      extractor.name = extract_name
      extractor.load_from_manifest
      extractor.models.each do |model|
        case ActiveRecord::Base.connection.adapter_name
        when /mysql|oracle|postgresql/i
          # Its dumb that this isn't in active record natively
          # https://github.com/rails/rails/issues/5510
          sql = "truncate table #{model.table_name}"
          # Postgresql flag to cascade delete for foreign key referenced tables
          sql << " CASCADE" if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
          ActiveRecord::Base.connection.execute(sql)
        else
          model.delete_all
        end
      end
      true
    end
  end
end

