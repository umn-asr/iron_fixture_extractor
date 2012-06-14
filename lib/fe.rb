require "fe/version"
require "active_record"
require 'active_record/fixtures'
require "active_support/all"
require "set" # introduced in Ruby standard lib in 1.9
require "fileutils"
module Fe
  extend ActiveSupport::Autoload
  autoload :Extractor
  autoload :YmlWriter
  autoload :Rebuilder
  autoload :Manifest

  # global configuration
   
  @@fixtures_root = 'test/fe_fixtures'
  mattr_accessor :fixtures_root

  # Top-level API methods
  class << self
    def extract(*args)
      extractor = Fe::Extractor.new(*args)
      extractor.write_fixtures
      extractor
    end

    def load_db(extract_name)
      extractor = Fe::Extractor.new_from_manifest(extract_name)
      extractor.load_into_database
      #manifest.mappings.each_pair do |key,hash|
        #ActiveRecord::Fixtures.create_fixtures(fixture_path_for_extract, hash['table_name'])
      #end
    end
    def rebuild(extract_name)
      
    end
  end
  # Internalish API methods used to support the top-level ones
  class << self
  end
end
