# About

When object factories don't work because your data is too complex and creating manual fixtures is cumbersome and brittle: Iron Fixture Extractor.

Iron fixture extractor makes extracting complex ActiveRecord dependency graphs from live databases sane.  Feed it an array of ActiveRecord objects that have preloaded associations via the .include method or just an adhoc array of ActiveRecord instances you want to capture as fixtures and it will write a bunch of fixture files for usage in your test cases.
          
                                     `###                       
                                      ,#                        
                                      +#,                       
                  ;+############++++++++++++++++++++++++++++    
                   ;                   +                  `:    
                  ##                  +#                  ++,   
                 .++`                 ;#;                 :+    
                  ''                  ;+`                `;;'   
                 ;::'                `;;.                +;;+'  
                :;:;':               +;;''              '+'+++: 
               `:';'++.             '+''+`;            .;;;;;''.
               :,'''';;            `````````                    

              ~|~ _ _  _         |~. _|_   _ _      (~ _|_ _ _  __|_ _  _
              _|_| (_)| |        |~|><||_|| (/_     (_><| | (_|(_ | (_)|

                   Iron             Fixture             Extractor
                                       is
                                    handy when
                      you require complex data extracted from 
                                 crusty legacy 
                                       or 
                                     big ERP
                                    databases
                                       for
                                    test cases.
    
## Installation
Add this line to your application's Gemfile:

    gem 'iron_fixture_extractor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iron_fixture_extractor

## Usage
The Iron Fixture Extractor gem exposes everything under the Fe
namespace, we'll refer to it as "Fe" from here on out.

Fe is designed to be used in an interactive Ruby shell or Rails console.
The idea is to poke around your data via your ActiveRecord models, then
once you have a good dataset, use Fe.extract to load it into fixture
files you can write tests against.

This gem is dirt simple--consider reading the source code
and test cases directly to clarify any behavioral details this readme
doesn't cover.

### Extract

    Fe.extract 'Post.includes(:comments, :author).limit(1)', name =>  'first_post_w_comments_and_authors'

### Load Fixtures (BE CAREFUL, THIS DELETES EVERYTHING IN THE TARGET TABLES)

    Fe.load_db(:first_post_w_comments_and_authors)

### Rebuild Fixture Files
This uses the fe_manifest.yml's extract_code to re-extract fixtures
using the same code used to initially create them.  Its handy when the live data changes and you want to refresh the fixture files to reflect it.

    Fe.rebuild(:first_post_w_comments_and_authors)

## How it works

### Extract
The essense of the Fe.extract algorithm is:

    for each record given to .extract             
      recursively resolve any association pre-loaded in the .association_cache [ActiveRecord] method 
      add it to a set of records keyed by model name
    write each set of records as a <model_name>.yml fixture file to test/fe_fixtures/<the :name specified to .extract>/ 

The magic is all in the recursive usage of ActiveRecord::Base#association_cache.  This means, that if you do something like:

    p=Post.first
    p.comments
    Fe.extract(p)

you will get 2 fixture files: 1 post record fixture (not-surprising) and N comment fixtures because p.association_cache is populated for :comments on the post instance p.

### Load Fixtures
This uses the same mechanism as Rails' `rake db:fixtures:load`, aka ActiveRecord::Fixtures.create_fixtures method

### Rebuild Fixture Files
This is just like .extract, except the code used to do the query is
pulled from the fe_manifest.yml file.

## Missing Features
* rake fe:fixtures:extract, fe:fixtures:load_db, and fe:fixtures:rebuild
  ought exist and be available in Rails context via a Railtie.  They would simply wrap the capabilities of Fe's extract, load_db, and rebuild method.
* If you give a non-string arg to .extract, the manifest should resolve
  the .extract_code to be a bunch of look-ups by primary key ala [Post.find(1),Comment.find(2)].
* The output of each of the main commands should be meaningful, aka,
  make extractor implement a sensible .to_s and .inspect 
* load_db should error if Rails.env or RAILS_ENV is defined and set to
  production

## Contributing
To run test cases:

    # clone or fork repo
    cd iron_fixture_extractor
    rake # runs test cases

Help on the missing features above would be much appreciated per the
usual github approach:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

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
