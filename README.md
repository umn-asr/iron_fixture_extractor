# About Iron Fixture Extractor

For extracting complex data from staging and production databases to be used for automated testing.

Its best when:

* your data is too complex for factories
* creating and maintaining manual fixtures is cumbersome and brittle

## Use cases

* Pulling data from a staging database containing vetted data that has
  been built up by the development team, users, or business analysts to be loaded and used
  as "archetypical" data structures in test cases or demos.

* Taking snapshots of production data that has triggered app exceptions 
  to be more closely inspected and incorporated into test cases.

## How it works

  Feed it an array of ActiveRecord objects or ActiveRelation object and
it will allow you to:

* extract data to .yml fixtures
* load it into a database or memory
* rebuild .yml fixtures from a saved ActiveRelation extraction query.

## Usage

### *Extract* fixture set (typically run in a rails console)

    Fe.extract 'Post.includes(:comments, :author).limit(1)', :name =>  'first_post_w_comments_and_authors'
    # or for multi-model extraction something like this:
    x = '[UserRole.all, Project.includes(:contributors => [:bio])]'
    Fe.extract(x,:name => :all_permissions_and_all_projects)

### *Load* fixture set into database (typically run in a "setup" test method )

    Fe.load_db(:first_post_w_comments_and_authors)

### *Load particular fixture into memory* (typically used to instantiate an object or build a factory)

    # 'r1' is the fixture's name, all fixture names start with 'r', 1 is the id
    Fe.get_hash(:first_post_w_comments_and_authors, Post, 'r1')

    # You can specify :first, or :last to the last arg
    Fe.get_hash(:first_post_w_comments_and_authors, Comment, :first)

    # Get the hash representation of the whole fixture file
    Fe.get_hash(:first_post_w_comments_and_authors, Comment, :all)

    # Get an array of hashes stored in a fixture file
    Fe.get_hashes(:first_post_w_comments_and_authors, Comment)

This feature is used to instantiate objects from the hash or define factories like:

    # Create factory from a particular hash within a fixture file
    Factory.create(:the_post) do
      h=Fe.get_hash(:first_post_w_comments_and_authors, Post, :first)
      name h.name
    end

    or

    # Create an instance
    h=Fe.get_hash(:first_post_w_comments_and_authors, Post, :first)
    ye_old_post=Post.new(h)

### *Rebuild* fixture files associated with the initial extraction (also doable via rake task in Rails)

    Fe.rebuild(:first_post_w_comments_and_authors)
    # Make sure to `diff` your test/fe_fixtures dir to see what has changed in .yml files

### *Truncate tables* associated with a fixture set (if you're not using DatabaseCleaner)

    Fe.truncate_tables_for(:first_post_w_comments_and_authors)

## Installation

Add this line to your application's Gemfile:

    gem 'iron_fixture_extractor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iron_fixture_extractor

## Advanced Usage/Changing fe_manifest.yml for fixture set

* Each extracted fixture set has a fe_manifest.yml file that contains
details about:

  * The ActiveRelation/ActiveRecord query to used to instantiate objects
to be serialized to .yml fixtures.
  * The models, table names, and row counts of records in the fixture set

By modifying the :extract_code: field, you can change the extraction
behavior associated with .rebuild. It can be handy if you want to add
data to a fixture set.

## Dirt Simple Shiznit

The essense of the Fe.extract "algorithm" is:

    for each record given to Fe.extract
      recursively resolve any association pre-loaded in the .association_cache [ActiveRecord] method
      add it to a set of records keyed by model name
    write each set of records as a <TheModel.table_name>.yml fixture
    write a fe_manifest.yml containing original query, row counts, etc

## Typical Workflow 
* Data extracted from a dev, staging, or production db is needed
* Open `rails console` in the appropriate environment
* Monkey with ActiveRecord queries to collect the data set you want to use in your test case.
* Represent the ActiveRecord query code as a string, i.e. `x=[User.all,Project.includes(:author).find(22)]'`
* Extract the data into fixtures, `Fe.extract(x,:name => :some_fixture_set_name)`
* Open up test/fe_fixtures/some_fixture_set_name and poke around the yml files to make sure you've captured what you need. Tweak `extract_name` if you need to and `.rebuild`
* In your test case's setup method:

    Fe.load_db(:some_fixture_set_name)
    ...then load a instance var to test against:
    ...in this case 22 is the id of a fixture that has just been loaded
    @the_project = Project.find(22)
    or
    Fe.execute_extract_code(:some_fixture_set_name).first
    
* In your test case's teardown method:

    DatabaseCleaner.clean...
    or
    Fe.truncate_tables_for(:some_fixture_set_name)

* In your test case `require 'debugger'; debugger; puts 'x'`...inspect @the_project or whatever does the loaded object and db state have the fixtures you want.
* Once things seem to be working-ish in your tests, add the fixtures to source control + test case that uses them.

## Gem Compatibility

* Works on MRI 1.9.3 and 1.9.2
* Does not work on JRuby, 1.8.7

## Contributing

See spec/README_FOR_DEVELOPERS.md, NOTE: MAJOR REFACTOR UNDERWAY TO SWITCH FROM SHOULDA TO RSPEC, TESTS ARE CURRENTLY BROKEN 


## Footnotes
I used various ideas from the following blog posts, gists, and existing
ruby gems, thanks to the authors of these pages:

* http://nhw.pl/wp/2009/09/24/extracting-fixtures
* http://nhw.pl/download/extract_fixtures.rake
* https://rubygems.org/gems/fixture_builder
* https://rubygems.org/gems/fixture_dependencies
* http://topfunky.net/svn/plugins/ar_fixtures/
* https://gist.github.com/997746
* https://gist.github.com/2686783
* http://snippets.dzone.com/posts/show/4729
* http://rubygems.org/search?utf8=%E2%9C%93&query=fixture
* http://www.dan-manges.com/blog/38
* http://www.martinfowler.com/bliki/ObjectMother.html
* http://asciicasts.com/episodes/158-factories-not-fixtures

## Author
Joe Goggins
