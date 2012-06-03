require 'rubygems'
require 'bundler'
Bundler.setup
require 'shoulda'
require 'fe'
case ENV['DBCONN'] || 'sqlite'
when 'sqlite'
  connection_type = 'sqlite'
else
  raise "error, sqlite only implemented db test drvier right now"
end
connections = YAML::load_file(File.join(File.dirname(__FILE__), 'config', 'database.yml'))
ActiveRecord::Base.establish_connection(connections[connection_type])
class ActiveSupport::TestCase
  # put crap here.
end
