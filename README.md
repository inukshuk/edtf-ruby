EDTF-Ruby
=========

Ruby implementation of the [Extended Date/Time Format
Specification](http://www.loc.gov/standards/datetime/spec.html).


Compatibility
-------------

EDTF-Ruby parser fully implements all levels and features of EDTF
Specification DRAFT, August 4, 2011.

The level 2 list extensions (203 and 204) currently return simple Ruby arrays;
therefore, advanced behavior (such as 'earlier' or 'later') is parsed correctly
but not yet exposed by the Ruby API.

EDTF-Ruby has been confirmed to work on the following Ruby implementations:
1.9.2, 1.8.7, Rubinius, and JRuby.


Quickstart
----------

EDTF Ruby is implemented as an extension to the regular Ruby date/time classes.
You can access parse EDTF strings either using `Date.edtf` or `EDTF.parse`; if
given a valid EDTF string the return value will either be an (extended) `Date`,
`EDTF::Interval` or `Range` (for masked precision strings) instance.

    $ [sudo] gem install edtf
    $ irb
    > require 'edtf'
    > d = Date.edtf('1984?')
    > d.uncertain?
    => true
    > d.certain!
    > d.uncertain?               
    => false
    > d = Date.edtf('1999-03-uu')
    > d.unspecified?
    => true
    > d.unspecified? :year
    => false
    > d.unspecified? :day
    => true
    > Date.edtf('2003-24').winter?
    => true
    > Date.edtf('196x')
    => #<Date: 1960-01-01>...#<Date: 1970-01-01>
    > Date.edtf('y-17e7').year
    => -170000000
    > d = Date.edtf('1984-06?/2004-08?')
    > d.from.uncertain?
    => true
    > d.to_a.length
    => 7397 # days between 1984-06-01 and 2004-08-31
    > Date.edtf('1582-10/1582-10').to_a.length
    => 21 # number of days in October 1582 (Gregorian calendar)
    > Date.edtf('2004/open').open?
    => true
    

For additional features take a look at the RDoc and RSpec examples.


Development
-----------

    $ git clone https://inukshuk@github.com/inukshuk/edtf-ruby.git
    $ cd edtf-ruby
    $ bundle install
    $ bundle exec rake racc_debug
    $ bundle exec rspec spec
    $ bundle exec cucumber

For extra credit, fork the project on GitHub: pull requests welcome!


Credits
-------

EDTF-Ruby was written by [Sylvester Keil](http://sylvester.keil.or.at) and
[Namyra](https://github.com/namyra).

Published under the terms and conditions of the FreeBSD License; see LICENSE
for details.
