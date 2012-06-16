# About

When object factories don't work because your data is too complex and creating manual fixtures is cumbersome and brittle: Iron Fixture Extractor.

                       `###                       
                        ,#                        
                         '                        
                        ,+,                       
                        +#,                       
    ;+############++++++++++++++++++++++++++++    
     ;                   +                  `:    
     :                   +                   :    
     .                   '                   :    
    .                    +                  `'    
    :.                   ,                  `'    
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

Iron fixture extractor makes extracting complex ActiveRecord dependency graphs from live databases sane.  Feed it an array of ActiveRecord objects that have preloaded associations via the .include method or just an adhoc array of ActiveRecord instances you want to capture as fixtures and it will write a bunch of fixture files for usage in your test cases.

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
    write each set of records as .yml fixtures to 

The magic is all in the recursive usage of ActiveRecord::Base#association_cache.  This means, that if you do something like:

    p=Post.first
    p.comments
    Fe.extract(p)

you will get 2 fixture files: 1 post record fixture and N comment
fixtures.

### Load Fixtures
This uses the same mechanism as Rails' `rake db:fixtures:load`, aka ActiveRecord::Fixtures.create_fixtures method

### Rebuild
This is just like .extract, except the code used to do the query is
pulled from the fe_manifest.yml file.

## Missing Features
* rake fe:fixtures:extract, fe:fixtures:load_db, and fe:fixtures:rebuild
  ought exist and be available in Rails context via a Railtie.  They would simply wrap the capabilities of Fe's extract, load_db, and rebuild method.
* If you give a non-string arg to .extract, the manifest should resolve
  the .extract_code to be a bunch of look-ups by primary key ala [Post.find(1),Comment.find(2)].
 
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
