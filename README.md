[![Code Climate](https://codeclimate.com/github/umn-asr/iron_fixture_extractor/badges/gpa.svg)](https://codeclimate.com/github/umn-asr/iron_fixture_extractor)
[![Build Status](https://travis-ci.org/umn-asr/iron_fixture_extractor.svg?branch=master)](https://travis-ci.org/umn-asr/iron_fixture_extractor)

# Iron Fixture Extractor

For extracting complex data from staging and production databases to be used for automated testing.

It's best when:

* your data is too complex for factories
* creating and maintaining manual fixtures is cumbersome and brittle

## Use cases

* Pulling data from a staging database containing vetted data that has been built up by the development team, users, or business analysts to be loaded and used as "archetypical" data structures in test cases or demos.

* Taking snapshots of production data that has triggered app exceptions to be more closely inspected and incorporated into test cases.

## How it works

Feed it an array of ActiveRecord objects or ActiveRelation object and it will allow you to:

* extract data to .yml fixtures
* load it into a database or memory
* rebuild .yml fixtures from a saved ActiveRelation extraction query.

## Usage

### *Extract* fixture set (typically run in a irb console)

```ruby
Fe.extract('Post.includes(:comments, :author).limit(1)', :name =>  'first_post_w_comments_and_authors')
```

or for multi-model extraction something like this:

```ruby
Fe.extract('[UserRole.all, Project.includes(:contributors => [:bio])]' ,:name => :all_permissions_and_all_projects)
```

### *Load* fixture set into database (typically run in a "setup" test method )

```ruby
Fe.load_db(:first_post_w_comments_and_authors)
```

If your fixture set is huge, you can avoid loading particular tables with:

```ruby
Fe.load_db(:first_post_w_comments_and_authors, :only => 'posts')
```

Or 

```ruby
Fe.load_db(:first_post_w_comments_and_authors, :except => ['comments'])
```

You can also load to a table name different than the source they were extracted from via a Hash or Proc:

Via Proc: (this will add "a_prefix_" to all target tables)

```ruby
Fe.load_db(:first_post_w_comments_and_authors, :map => -> table_name { "a_prefix_#{table_name}" })
```

Via Hash: (just maps posts to different table, the others stay the same)

```ruby
Fe.load_db(:first_post_w_comments_and_authors, :map => {'posts' => 'different_posts'})
```

### *Load particular fixture into memory* (typically used to instantiate an object or build a factory)

'r1' is the fixture's name, all fixture names start with 'r', 1 is the id
```ruby
Fe.get_hash(:first_post_w_comments_and_authors, Post, 'r1')
```

You can specify :first, or :last to the last arg
```ruby
Fe.get_hash(:first_post_w_comments_and_authors, Comment, :first)
```

Get the hash representation of the whole fixture file
```ruby
Fe.get_hash(:first_post_w_comments_and_authors, Comment, :all)
```

Get an array of hashes stored in a fixture file
```ruby
Fe.get_hashes(:first_post_w_comments_and_authors, Comment)
```

This feature is used to instantiate objects from the hash or define factories like:

Create factory from a particular hash within a fixture file

```ruby
Factory.create(:the_post) do
  h=Fe.get_hash(:first_post_w_comments_and_authors, Post, :first)
  name h.name
end
```
or create an instance

```ruby
h=Fe.get_hash(:first_post_w_comments_and_authors, Post, :first)
ye_old_post=Post.new(h)
```

### Setting facts and using them in testing

Within a fixture you can set facts that you can then use in tests. To set a fact:

```ruby
fact_value = 200
Fe.create_fact('fixture_name', 'fact_name', fact_value)
Fe.fact('fixture_name', 'fact_name')
#=> 200
```

Within a test:

```
expect(thing_under_test).to eq(Fe.fact(:fixture_name, :fact_name))
```

### *Rebuild* fixture files associated with the initial extraction (also doable via rake task in Rails)

```ruby
Fe.rebuild(:first_post_w_comments_and_authors)
```

Make sure to `diff` your test/fe_fixtures dir to see what has changed in .yml files

### *Truncate tables* associated with a fixture set (if you're not using DatabaseCleaner)

```ruby
Fe.truncate_tables_for(:first_post_w_comments_and_authors)
```

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

## The Basic Algorithm

The essence of the Fe.extract "algorithm" is:

- for each record given to Fe.extract
  - recursively resolve any association pre-loaded in the .association_cache [ActiveRecord] method
  - add it to a set of records keyed by model name
- write each set of records as a <TheModel.table_name>.yml fixture
- write a fe_manifest.yml containing original query, row counts, etc

## Typical Workflow 
* Data extracted from a dev, staging, or production db is needed
* Open `rails console` in the appropriate environment
* Monkey with ActiveRecord queries to collect the data set you want to use in your test case.
* Represent the ActiveRecord query code as a string, i.e. `x='[User.all,Project.includes(:author).find(22)]'`
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

* Tested on all versions of Ruby listed in our [.travis.yml](Travis Configuration)

## Contributing

In a nutshell:

    git clone     # get the code
    cd <the dir>
    rake          # run the tests
    # make a spec file and hack.

See spec/README_FOR_DEVELOPERS.md for more details.

#### TODO: JOE REPLACE THE ABOVE CONTENT WITH THIS METHOD
Alternatively, another way to lower the barrier to contributing is to submodule the Gem into your project
and hack in the features you need to support your app specific, then add
a test case to the Gem itself that illustrates your change...

#### TODO: Write a "For Rspec users", include an initializer:

    # config/initializers/iron_fixture_extractor.rb
    Fe.fixtures_root = 'spec/fe_fixtures' if defined?(Fe)

#### TODO: Write something up about bug with has_many :through
* If you have a query that utilizes a has_many :through.  Make sure to
put the table that facilitates the :through AFTER the one that uses it.
ie.

    # NOT WORKING
    query='Etl::Receipt.includes(:audits, :instcd_to_jobid_mappings, :dars_job_queue_lists  => {:job_queue_runs => [:job_queue_outs, {:job_queue_reqs => {:job_queue_subreqs  => :job_queue_courses}}]})'
    t=Fe.extract(query,:name => 'poo')

    # WORKING
    query='Etl::Receipt.includes(:audits, {:dars_job_queue_lists  => {:job_queue_runs => [:job_queue_outs, {:job_queue_reqs => {:job_queue_subreqs  => :job_queue_courses}}]}}, :instcd_to_jobid_mappings)'
    t=Fe.extract(query,:name => 'poo')

* Beers, kudos, praise, and glory for a developer who can find the
reason for this and a fix...I tried, but couldn't figure it out, hence
the work around.

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
Joe Goggins & UMN ASR Custom Solutions
