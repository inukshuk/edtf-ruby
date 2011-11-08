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
    > d.include?(Date.new(1987,04,13))
    => false # the day is not included because interval has month precision    
    > d.cover?(Date.new(1987,04,13))
    => true # but the day is still covered by the interval
    > d.to_a.length
    => 243 # months between 1984-06-01 and 2004-08-31
    > Date.edtf('1582-10-01/1582-10-31').to_a.length
    => 21 # number of days in October 1582 (Gregorian calendar)
    > Date.edtf('2004/open').open?
    => true
    

For additional features take a look at the RDoc and the RSpec examples.


Contributing
------------

The EDTF-Ruby source code is [hosted on GitHub](https://github.com/inukshuk/edtf-ruby).
You can check out a copy of the latest code using Git:

    $ git clone https://github.com/inukshuk/edtf-ruby.git
    
To get started, generate the parser and run all tests:

    $ cd edtf-ruby
    $ bundle install
    $ bundle exec rake racc_debug
    $ bundle exec rspec spec
    $ bundle exec cucumber

If you've found a bug or have a question, please open an issue on the
[EDTF-Ruby issue tracker](https://github.com/inukshuk/edtf-ruby). Or, for extra
credit, clone the EDTF-Ruby repository, write a failing example, fix the bug
and submit a pull request.


Credits
-------

EDTF-Ruby was written by [Sylvester Keil](http://sylvester.keil.or.at) and
[Namyra](https://github.com/namyra).

Published under the terms and conditions of the FreeBSD License; see LICENSE
for details.
