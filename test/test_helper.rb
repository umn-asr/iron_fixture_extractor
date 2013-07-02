require 'rubygems'
require 'bundler'
Bundler.setup
require 'shoulda'
require 'iron_fixture_extractor'
# TEMP, COMMENT OUT IF NEEDED
require 'sqlite3'
require 'fe_test_env'
#ActiveRecord::Migration.verbose = false
FeTestEnv.reload
