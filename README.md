# About

When factories don't work, manual fixture generation is cumbersome and
brittle, bust out the Iron Fixture Extractor!

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

    $ gem install fe

## Usage
The Iron Fixture Extractor gem exposes everything under the Fe
namespace, we'll refer to it as "Fe" from here on out.

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
