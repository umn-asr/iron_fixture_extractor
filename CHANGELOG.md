## 1.1.0 -> 1.1.0
* Deprecation warning for fe_manifest.yml's extracted from 1.0.0 or earlier.

* Fix for Oracle reset pk seq (didn't work on 1.1.0)

## 1.0.0 -> 1.1.0
* Shouldn't be any breaking changes, mostly a switch to rspec for
testing.

* Added Fe.load_db(...) :only, :except, and :map options

## 0.1.1 -> 1.0.0
* Fe.extract must be given a string or array of ActiveRecord queries
  like this

* Fe.get_hash, truncate_tables_for, execute_extract_code,
  to_factory_girl_string, make their debut...only get_hash is truly
awesome...the others...not so much

