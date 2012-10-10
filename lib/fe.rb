# NOTE: require 'iron_fixture_extractor', NOT this file
module Fe
  extend ActiveSupport::Autoload
  autoload :Extractor
  require 'fe/railtie' if defined?(Rails)

  # global configuration
   
  @@fixtures_root = 'test/fe_fixtures'
  mattr_accessor :fixtures_root

  # Top-level API methods
  class << self
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

    # NOTE: This is destructive, it will delete everything in the target table
    #
    def load_db(extract_name)
      extractor = Fe::Extractor.new
      extractor.name = extract_name
      extractor.load_from_manifest
      extractor.load_into_database
      extractor
    end
    def rebuild(extract_name)
      extractor = Fe::Extractor.new
      extractor.name = extract_name
      extractor.load_from_manifest
      extractor.extract
      extractor
    end

    def get_hash(extract_name, model_name, fixture_name)
      model_name = model_name.to_s 
      extractor = Fe::Extractor.new
      extractor.name = extract_name

      begin
        h=extractor.fixture_hash_for_model(model_name)
      rescue Exception => e
        raise "Fe::Extractor#fixture_hash_for_model broke on #{model_name}"
      end
      raise "#{h.inspect} Fe::Extractor#fixture_hash_for_model did not return a hash (broken fixture file)" unless h.kind_of? Hash

      fixture_path_for_model = extractor.fixture_path_for_model(model_name)
      raise "Fixture of the name #{fixture_name} did not exist in in #{fixture_path_for_model}" unless h.has_key?(fixture_name)

      h[fixture_name]
    end
  end
end
