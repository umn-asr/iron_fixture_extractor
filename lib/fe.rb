# NOTE: require 'iron_fixture_extractor', NOT this file
module Fe
  extend ActiveSupport::Autoload
  autoload :Extractor

  # global configuration
   
  @@fixtures_root = 'test/fe_fixtures'
  mattr_accessor :fixtures_root

  # Top-level API methods
  class << self
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
  end
end
