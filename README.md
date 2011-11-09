EDTF-Ruby
=========

Ruby implementation of the [Extended Date/Time Format
Specification](http://www.loc.gov/standards/datetime/spec.html).


Compatibility
-------------

EDTF-Ruby parser implements all levels and features of the EDTF specification
(version September 16, 2011). With the following known caveats:

* Uncertain/approximate seasons will be parsed, but the Season class does
  not implement attributes.
* In the latest revision of the EDTF specification alternative versions of
  partial uncertain/approximate strings were introduced (with or without nested
  parentheses); EDTF-Ruby currently uses the version that tries to reduce
  parentheses for printing as we find that one easier to read; the
  parser accepts all valid dates using this approach, plus some dates using
  nested expressions (the parser will not accept some of the more complex
  examples, though).

EDTF-Ruby has been confirmed to work on the following Ruby implementations:
1.9.3, 1.9.2, 1.8.7, Rubinius, and JRuby. Active Support's date extensions
are currently listed as a dependency, because of a number of many functional
overlaps.


Quickstart
----------

EDTF Ruby is implemented as an extension to the regular Ruby date/time classes.
You can access parse EDTF strings either using `Date.edtf` or `EDTF.parse`
(both methods come with an alternative bang! version, that will raise an error
if the string cannot be parsed instead of silently returning nil); if
given a valid EDTF string the return value will either be an (extended) `Date`,
`EDTF::Interval`, `EDTF::Set`, or `Range` (for masked precision strings)
instance. Given a Date, you can print the corresponding EDTF string using the
`#edtf` method.

    $ [sudo] gem install edtf
    $ irb
    > require 'edtf'
    > d = Date.edtf('1984?')
    > d.uncertain?
    => true
    > d.approximate!
    > d.edtf
    => "1984?~"
    > d = Date.edtf('1999-03-uu')
    > d.unspecified?
    => true
    > d.unspecified? :year
    => false
    > d.unspecified? :day
    => true
    > d.unspecified! :month
    > d.edtf
    => "1999-uu-uu"
    > Date.edtf!('2003-24').winter?
    => true
    > Date.edtf!('196x')
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
    > d.length
    => 243 # months between 1984-06-01 and 2004-08-31
    > d.step(36).map(&:year)
    => [1984, 1987, 1990, 1993, 1996, 1999, 2002] # 36-month steps
    > Date.edtf('1582-10-01/1582-10-31').length
    => 21 # number of days in October 1582 (Gregorian calendar)
    > Date.edtf('2004/open').open?
    => true
    > Date.edtf('2004/open').cover?(Date.today)
    => true # an open ended interval covers today
    > Date.edtf("(1999-(02)~-23)?").edtf
    => "1999?-(02)?~-23?" # when printing, EDTF-Ruby reduces nested parentheses
    > s = Date.edtf('{1667,1668, 1670..1672}')
    > s.include?(Date.edtf('1669'))
    => false
    > s.include?(Date.edtf('1671'))
    => true # the range is enumerated for membership tests
    > s.length
    => 3 # but we're still aware that there were only three elements
    > s.map(&:year)
    => [1667, 1668, 1670, 1671, 1672] # when enumerated there are 5 elements
    > s.earlier?
    => false # the original list was not vague
    > s.earlier! # but we can make it so
    > s.edtf
    => "{..1667, 1668, 1670..1672}"


For additional features take a look at the documentation or the extensive
list of rspec examples.


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
