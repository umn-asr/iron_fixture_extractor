require "fe/version"
require "active_record"
require "active_support/all"
module Fe
  # global configuration
   
  @@fixtures_root = 'test/fe_fixtures'
  mattr_accessor :fixtures_root

  # Top-level API methods
  class << self
    def extract(query,*args)
      options = args.extract_options!
      "Wrote TODO"
    end
  end
  # Internalish API methods used to support the top-level ones
  class << self
  end
end
