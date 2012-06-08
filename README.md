# About
Iron fixture extractor (Fe) makes extracting complex ActiveRecord dependency graphs from live databases sane.  Feed it an array of ActiveRecord objects that have preloaded associations via the .include method and it will write a bunch of fixture files for usage in test cases that require the hairy data extracted from your gnarly real-world production database.

It was designed to tackle the problem of writing test cases against
crust-ware software systems that have been here since the stone age:
neither manually generated fixtures or factory based methods do an
adequate job capturing the data for test cases--in these cases, you have
to get to the metal.

## Installation
Add this line to your application's Gemfile:

    gem 'fe'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fe

## Usage
For the examples below, assume the following models:
(Note: Look at the test cases for more up-to-date and thorough examples)

    class CrustwareApp < ActiveRecord::Base
      has_many :crusty_features
    end

    class CrustyFeature < ActiveRecord::Base
      belongs_to :crustware_app
      belongs_to :cobol_programmer_owner, :class_name => 'CobolProgrammer'
    end

    # No dis against cobol programmers here, I wish I knew that shit
    #
    class CobolProgrammer < ActiveRecord::Base
      has_many :crusty_features
    end

Fe is designed to be used in an interactive Ruby shell or Rails console,
if you want a rake task or whatever, feel free to wrap it up as you see
fit.

### Usage in Ruby
#### Extract
  Fe.extract 'Post.includes(:comments, :author).limit(1)', name: 'first_post_w_comments_and_authors'
  =>
    Wrote 3 fixture files to /test/fe_fixtures/first_post_w_comments_and_authors
      post.yml (2 records, 4.3 kilo-bytes)
      comment.yml (5 records, 4.3 kilo-bytes)
      author.yml (1 records, 4.3 kilo-bytes)
      fe_manifest.yml (used by Fe.rebuild(:first_post_w_comments_and_authors))
   
#### Rebuild
  Fe.rebuild(:first_post_w_comments_and_authors)

### Usage via Rake/Command Line
rake is just a wrapper for calls for the main Fe API methods like
.extract and .rebuild, you might run extract like:

  rake fe:extract "'Post.includes(:comments, :author).limit(1)', name: 'first_post_w_comments_and_authors'"

to make the rake tasks included with the gem available to your app,
TODO: SPECIFY

    
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


-----------------------------------------------------
= About
This is proof of concept and research for dynamic fixture extraction
from this "Dynamic Fixtures" google doc:
https://docs.google.com/a/umn.edu/document/d/1dIMZl5flZKOj_lldlWK1TTNVRZce0OCrCptD1YvyGY4/edit

== Modify existing rake task
This might exactly the solution I'm looking for:
  http://nhw.pl/download/extract_fixtures.rake
=== Usage poc
rake extract_fixtures[entries,10,"id=1 OR id=2 OR id=3)"].
rake extract_fixtures[etl_audits,poo,"id=1 OR id=2 OR id=3)"].




# Poof Fixture Extractor Usage
This is the 

## Example Usage
* rake poof:extract scenario=demo ar=Ps::Person.limit(1)
  * Creates
      test/poof_fixtures/demo/ps/person.yml

* rake poof:extract scenario=demo ar=Ps::Person.includes(:names).limit(1)
  * Creates
      test/poof_fixtures/demo/ps/person.yml
      test/poof_fixtures/demo/ps/names.yml

  * Recon
 > ar=Ps::Person.joins(:names).limit(1)
 > ar.joins.ast.cores[0].source.right[0].left.name
 => "asr_warehouse.ps_names" 

ar=Ps::Person.includes(:names).limit(1)
ar[0].names.loaded?
=> true
ar=Ps::Person.includes(:names,:acad_progs).limit(1)
ar[0].association_cache.first.last.target
 => [#<Ps::AcadProg emplid: "0010094">]

require 'set'
to_poof = {}
def recursor(ars)
  ars=Array(ars)
  ars.each do |ar|
    ar.association_cache.each do |assoc_cache|
      to_poof[assoc_cache.last.target.class] ||= Set.new
      if assoc_cache.last.target.kind_of? ActiveRecord::Base
        to_poof[assoc_cache.last.target.class].add assoc_cache.last.target
        recursor(assoc_cache.last.target)
      elsif assoc_cache.last.target.kind_of? Enumerable
        assoc_cache.last.target.each do |rec|
          to_poof[rec.class].add rec
          recursor(rec)
        end
      end
    end
  end
end
recursor(Ps::Person.includes(:names, :acad_progs).limit(1))
to_poof => {Ps::Person => Set,
    Ps::Names  => Set,
    Ps::AcadProg => Set}

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

y=Poof::FixtureWriter.new(:demo,x)
y.write

z=Poof::FixtureLoader.new(:demo)
z.data_collection == x
=> true

z.localize_models_to_db(:test)
=> true # goes in and switches out the .table_name for each model in the
data collection

z.load
=> true # generates a low level sql insert statement to insert the data











TOMORROW:
Write a function that recursively goes through
each association looking for those that are already loaded
and builds an hash indexed by model name (class type returned by
association) with values of arrays of rows to be .to_yml'ed

If there are associations that are self-referential, (i.e. employee has
boss), then add rows to the array of data for that model.

Avoid end-less recursion by building a list of [primary key] ids for each model
that has been iterated over, and don't do the recursion if its in this
list.







Before serializing

## Input
* command: extract|load|unload
* scenario name
* source database
* target database

## Output
rake poof:extract
reload


Research

http://nhw.pl/wp/2009/09/24/extracting-fixtures


