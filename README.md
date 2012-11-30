# About Iron Fixture Extractor

For extracting complex data from staging and production databases to be used for automated testing (works great with whatever testing framework your using).

Its best when:
* your data is too complex for factories (like when integrating with legacy systems, ERP systems, etc)
* creating and maintaining manual fixtures is cumbersome and brittle (always, :))

Its good for:

  Pulling data from a staging database containing vetted data that has
  been built up by the development team, users, or business analysts to be used
  as "archetypical" data structures in test cases, demonstration.

  Taking snapshots of production data that has triggered unexpected errors to be incorporated into test cases for closer inspection and correction.

How it works:

  Feed it an array of ActiveRecord objects or ActiveRelation object and it will allow you to extract, load, and rebuild the records associated with your queries.

## Usage
### Extract (fixture files, typically run in an irb/"rails console")

    Fe.extract 'Post.includes(:comments, :author).limit(1)', :name =>  'first_post_w_comments_and_authors'

### Load (dataset into database, typically run in a "setup" test method )

    Fe.load_db(:first_post_w_comments_and_authors)

### Rebuild (fixture files associated with the initial extraction, typically via rake task (in Rails))

    Fe.rebuild(:first_post_w_comments_and_authors)

### Truncate tables (associated with a fixture set...if you're not using DatabaseCleaner)

    Fe.truncate_tables_for(:first_post_w_comments_and_authors)

### Pull up a hash from a particular fixture file (very handy)

    # 'r1' is the fixture's name, all fixture names start with 'r', 1 is the id
    Fe.get_hash(:first_post_w_comments_and_authors, Post, 'r1')

    # You can specify :first, or :last to the last arg
    Fe.get_hash(:first_post_w_comments_and_authors, Comment, :first)

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

### 
## Installation
Add this line to your application's Gemfile:

    gem 'iron_fixture_extractor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iron_fixture_extractor

### Extract
The essense of the Fe.extract is dirt simple:

    for each record given to Fe.extract
      recursively resolve any association pre-loaded in the .association_cache [ActiveRecord] method
      add it to a set of records keyed by model name
    write each set of records as a <TheModel.table_name>.yml fixture
    write a fe_manifest.yml that will allow you to later change the query, inspect row counts, and rebuild the fixtures by re-executing the originate queries

## Compatibility
* Works on MRI 1.9.3 and 1.9.2
* Does not work on JRuby, 1.8.7

## Feature Wishlist
* Get this to work on JRuby: jigger the Gemfile, .gemspec, and
  test_helper.rb
* If you give a non-string arg to .extract, the manifest should resolve
  the .extract_code to be a bunch of look-ups by primary key ala [Post.find(1),Comment.find(2)].
* The output of each of the main commands should be meaningful, aka,
  make extractor implement a sensible .to_s and .inspect 
* load_db should error if Rails.env or RAILS_ENV is defined and set to
  production
* An :extract_schema option passed to .extract that uses `rake db:structure:dump` functionality 
  or ActiveRecord::Base.connection.structure_dump to create .sql files containing a "create table" statement
  for each distinct model class.  This would allow you to completely de-couple your test cases + fixtures
  from the external databases they were extracted from.

## Contributing
To run test cases:

    # clone or fork repo
    cd iron_fixture_extractor
    rake # runs test cases

Help on the missing features above would be much appreciated per the
usual github approach:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Ensure the test cases run
4. Copy one of the test cases (like basic_test.rb), rename, rip out the guts, and add some tests + code to the app
5. Commit your changes (`git commit -am 'Added some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

If you have other ideas for this tool, make a Github Issue.

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
