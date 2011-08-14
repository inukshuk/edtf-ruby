EDTF-Ruby
=========

Ruby implementation of the [Extended Date/Time Format
Specification](http://www.loc.gov/standards/datetime/spec.html).


Compatibility
-------------

As of EDTF Specification DRAFT, August 4, 2001:

* Level 0: fully implemented
* Level 1: fully implemented
* Level 2: implemented features 204, 207, 208, and 209

The following level 2 extensions are currently _not_ supported: 201, 202, 203,
204, and 205.


Quickstart
----------

EDTF Ruby is implemented as an extension to the regular Ruby date/time classes.
You can access parse EDTF strings either using `Date.edtf` or `EDTF.parse`; if
given a valid EDTF string the return value will either be an (extended) `Date`,
`EDTF::Interval` or `Range` (for masked precision strings) instance.

    $ [sudo] gem install edtf
    $ irb
    > require 'edtf'
    > 

For additional features take a look at the rdoc, source, and rspec examples.


Development
-----------

    $ git clone https://inukshuk@github.com/inukshuk/edtf-ruby.git
    $ cd edtf-ruby
    $ bundle install
    $ bundle exec rake racc
    $ bundle exec rspec spec
    $ bundle exec cucumber

For extra credit, fork the project on github: pull requests welcome!

Credits
-------

EDTF-Ruby was written by [Sylvester Keil](http://sylvester.keil.or.at).

Published under the terms and conditions of the FreeBSD License; see LICENSE
for details.
