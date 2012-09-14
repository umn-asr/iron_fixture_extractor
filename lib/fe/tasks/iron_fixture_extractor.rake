namespace :iron_fixture_extractor do
  desc "Executes Fe.rebuild(extract_name) to re-create an existing fixture file set"
  task :rebuild, [:extract_name] => :environment do |t,args|
    Fe.rebuild(args[:extract_name].to_sym)
  end

  desc "Executes Fe.load_db(extract_name) to insert rows associated with file set"
  task :load_db, [:extract_name] => :environment do |t,args|
    Fe.load_db(args[:extract_name].to_sym)
  end

end
