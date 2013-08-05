About Contributing to this Tool
===============================

All current and future work in managed via [GitHub issues and milestones](https://github.com/joegoggins/iron_fixture_extractor/issues?state=open).  Take a look there first.

Running Tests
-------------

### Run the whole test suite:

    rake

### Run an individual spec

    bundle exec spec/<A_SPEC_FILE>.rb

Notes
-----

* Uses sqlite to do testing, if you run into a bug that only happens in
  Oracle, MySQL, etc, you could try forking it, submoduling the gem into you project,
  and hacking on it within your project.  Feel free to submit an
  issue/pull request even if there isn't tests to cover your
  changes--we'll find a way to test it.
  
* If you have other ideas for this tool, make a Github Issue.
