module Fe
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(File.dirname(__FILE__),'tasks','iron_fixture_extractor.rake')
    end
  end
end
