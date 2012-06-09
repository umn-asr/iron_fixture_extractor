# TO FINISH/RELEASE GEM
* Write and expose rake tasks to Rails environment via Railtie
* Create the .rebuild function and writing of fe_manifest.rb
  >>> ALl of the stats from .extract should be written to the
  >>> fe_manifest with a datetime as well.

* Figure how to deal with localizing model table_names...
  For example when we load Ps::Person into a test database, the table
name the models are bound to needs to change...seems out of scope of
this tool

TODO: do something with this:
https://docs.google.com/a/umn.edu/document/d/1dIMZl5flZKOj_lldlWK1TTNVRZce0OCrCptD1YvyGY4/edit

# About
Iron fixture extractor (Fe) makes extracting complex ActiveRecord dependency graphs from live databases sane.  Feed it an array of ActiveRecord objects that have preloaded associations via the .include method and it will write a bunch of fixture files for usage in test cases that require the hairy data extracted from your gnarly real-world production/external/legacy database.

This gem is handy when:
* you need real data for test cases
* factories are worthless because the underlying data is too complex  
* manual fixture creation would be time consuming and brittle

Fe was initially designed to tackle the problem of writing test cases against
crust-ware software systems that have been here since the stone age:
neither manually generated fixtures or factory based methods do an
adequate job capturing representative data for test cases--in these cases, you have
to get to the metal.

## Installation
Add this line to your application's Gemfile:

    gem 'fe'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fe

## Usage
Fe is designed to be used in an interactive Ruby shell or Rails console.
The idea is to poke around your data via your ActiveRecord models, then
once you have a good dataset, use Fe.extract to load it into fixture
files you can write tests against.

### Extract
  Fe.extract 'Post.includes(:comments, :author).limit(1)', name: 'first_post_w_comments_and_authors'
  =>
    Wrote 3 fixture files to /test/fe_fixtures/first_post_w_comments_and_authors
      post.yml (2 records, 4.3 kilo-bytes)
      comment.yml (5 records, 4.3 kilo-bytes)
      author.yml (1 records, 4.3 kilo-bytes)
      fe_manifest.yml (used by Fe.rebuild(:first_post_w_comments_and_authors))
   
### Load
  Fe.load_db(:first_post_w_comments_and_authors)
  =>
    Loaded 3 fixture files to fake_test database from /test/fe_fixtures/first_post_w_comments_and_authors
      Post (2 record)
      Comment (5 records)
      Author (1 record)

### Rebuild Fixture Files
  Fe.rebuild(:first_post_w_comments_and_authors)
  =>
    Rewrote fixture files in /test/fe_fixtures/first_post_w_comments_and_authors
      (<<<same output as extract>>>)

## Missing Features
* rake fe:fixtures:extract, fe:fixtures:load_db, and fe:fixtures:rebuild
  ought exist and be available in Rails context via a Railtie.  They would simply wrap the capabilities of Fe's extract, load_db, and rebuild method.
 
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Footnotes
Before writing this Gem, I investigated the following approaches to get ideas, thanks to the authors behind these tools, blog posts, etc.
* http://nhw.pl/wp/2009/09/24/extracting-fixtures
  http://nhw.pl/download/extract_fixtures.rake

## SCRAPS TO DELETE/PROCESS
 > ar=Ps::Person.joins(:names).limit(1)
 > ar.joins.ast.cores[0].source.right[0].left.name
 => "asr_warehouse.ps_names" 


x=Poof::DataCollection.new(Ps::Person.includes(:names, :acad_progs).limit(1))
x.set_columns_for(Ps::Person, :emplid)
x.set_columns_for(Ps::Names, [:emplid,:name_type])
x.set_columns_for(Ps::AcadProg, [:emplid,:acad_prog])
x.data =>
  {Ps::Person => Hash
   Ps::Names => Hash
   Ps::AcadProg => Hash
  }
  # where each hash is restricted to just the columns specified
z.localize_models_to_db(:test)
=> true # goes in and switches out the .table_name for each model in the
data collection

## Input
* command: extract|load|unload
* scenario name
* source database
* target database

## Output
rake poof:extract
reload
