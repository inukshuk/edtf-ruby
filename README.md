EDTF-Ruby
=========
[![Build Status](https://travis-ci.org/inukshuk/edtf-ruby.png?branch=master)](https://travis-ci.org/inukshuk/edtf-ruby)
[![Coverage Status](https://coveralls.io/repos/inukshuk/edtf-ruby/badge.png)](https://coveralls.io/r/inukshuk/edtf-ruby)

EDTF-Ruby comprises a parser and an API implementation of the [Extended
Date/Time Format standard](http://www.loc.gov/standards/datetime/).


Compatibility
-------------
EDTF-Ruby parser implements all levels and features of the EDTF specification
(version September 16, 2011). With the following known caveats:

* In the latest revision of the EDTF specification alternative versions of
  partial uncertain/approximate strings were introduced (with or without
  nested parentheses); EDTF-Ruby currently uses the version that tries to
  reduce parentheses for printing as we find that one easier to read; the
  parser accepts all valid dates using this approach, plus some dates using
  nested expressions (the parser will not accept some of the more complex
  examples, though).

EDTF-Ruby has been confirmed to work on the following Ruby implementations:
2.1, 2.0, 1.9.3, Rubinius, and JRuby (1.8.7 and 1.9.2 were originally supported
but we are not testing compatibility actively anymore). Active Support's date
extensions are currently listed as a dependency, because of many functional
overlaps (version 3.x and 4.x are supported).


Quickstart
----------
EDTF Ruby is implemented as an extension to the regular Ruby date/time classes.
You can parse EDTF strings either using `Date.edtf` or `EDTF.parse`
(both methods come with an alternative bang! version, that will raise an error
if the string cannot be parsed instead of silently returning nil); if
given a valid EDTF string the return value will either be an (extended) `Date`,
`EDTF::Interval`, `EDTF::Set`, `EDTF::Epoch` or `EDTF::Season` instance.

Given any of these instances, you can print the corresponding EDTF string
using the `#edtf` method.

### Dates

Most of the EDTF features deal with dates; EDTF-Ruby implements these by
extending Active Support's version of the regular Ruby Date class. The library
intends to be transparent to Ruby's regular API, i.e., every Date instance
should act as you would normally expect but provides additional functionality.

Most, notably, EDTF dates come in day, month, or year precision. This is a
subtle difference that determines how many other methods work. For instance:

    > Date.today.precision
    => :day
    > Date.today
    => Thu, 10 Nov 2011
    > Date.today.succ
    => Fri, 11 Nov 2011
    > Date.today.month_precision!.succ
    => Sat, 10 Dec 2011

As you can see, dates have day precision by default; after setting the date's
precision to month, however, the natural successor is not the next day, but
a day a month from now. Always keep precision in mind when comparing dates,
too:

    > Date.new(1966).year_precision! == Date.new(1966)
    => false

The year 1966 is not equal to the January 1st, 1966. You can set a date's
precision directly, or else use the dedicated bang! methods:

    > d = Date.new(1993)
    > d.day_precision?   # -> true
    > d.edtf
    => "1993-01-01"
    > d.month_precision!
    > d.edtf
    => "1993-01"
    > d.year_precision!
    > d.edtf
    => "1993"
    > d.day_precision?    # -> false
    > d.year_precision?   # -> true

In the examples above, you also see that the `#edtf` method will print a
different string depending on the date's current precision.

The second important extension is that dates can be uncertain and or
approximate. The distinction between the two may seem somewhat contrived,
but we have come to understand it as follows:

Assume you take a history exam and have to answer one of those dreaded
questions that require you to say exactly in what year a certain event
happened; you studied hard, but all of a sudden you are *uncertain*: was
that the year 1683 or was it 1638? This is what uncertainty is in the
parlance of EDTF: in fact, you would write it just like that "1638?".

Approximate dates are similar but slightly different. Lets say you want
to tell a story about something that happened to you one winter; you
don't recall the exact date, but you know it must have been sometime
between Christmas and New Year's. Come to think of it, you don't
remember the year either, but you must have been around ten years old.
Using EDTF, you could write something like "1993~-12-(27)~": this
indicates that both the year and the day are approximations: perhaps
the day is not the 27th but it is somewhere close.

This is the main difference between uncertain and approximate in
EDTF (in our opinion at least): approximate always means close to the
actual number, whilst uncertain could be something completely different
(just as there is a large temporal distance between 1638 and 1683).

Here are a few examples of how you can access the uncertain/approximate
state of dates in Ruby:

    > d = Date.edtf('1984?')
    > d.uncertain?
    => true
    > d.uncertain? :year
    => true
    > d.uncertain? :day
    => false
    > d.approximate!
    > d.edtf
    => "1984?~"
    > d.month_precision!
    > d.approximate! :month
    > d.edtf
    => "1984?-01~"

As you can see above, you can use the bang! methods to set individual date
parts.

In addition, EDTF supports *unspecified* date parts:

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

All three, uncertain, approximate, and unspecified attributes do not factor
into date calculations (like comparisons or successors etc.).

EDTF long or scientific years are mapped to normal date instances.

    > Date.edtf('y-17e7').year
    => -170000000

When printing date strings, EDTF-Ruby will try to avoid nested parentheses:

    > Date.edtf("(1999-(02)~-23)?").edtf
    => "1999?-(02)?~-23?"


### Intervals

If you parse an EDTF interval, the EDTF-Ruby parser will return an instance
of `EDTF::Interval`; intervals mimic regular Ruby ranges, but offer additional
functionality.

    > d = Date.edtf('1984-06?/2004-08?')
    > d.from.uncertain?
    => true
    > d.include?(Date.new(1987,04,13))
    => false

The day is not included because interval has month precision. However:

    > d.cover?(Date.new(1987,04,13))
    => true

The day is still covered by the interval. In general, optimized in the
same way that Ruby optimizes numeric ranges. Additionally, precision
plays into the way intervals are enumerated:

    > d.length
    => 243

There are 243 months between 1984-06-01 and 2004-08-31.

    > d.step(36).map(&:year)
    => [1984, 1987, 1990, 1993, 1996, 1999, 2002]

Here we iterate through the interval in 36-month steps and map each date to
the year.

    > Date.edtf('1582-10-01/1582-10-31').length
    => 21

This interval has day precision, so 21 is the number of days in October 1582,
which was cut short because of the Gregorian calendar reform.

Intervals can be open or have unknown start or end dates.

    > Date.edtf('2004/open').open?
    => true
    > Date.edtf('2004/open').cover?(Date.today)
    => true

### Sets

EDTF supports two kind of sets: choice lists (meaning one date out of a list),
or inclusive lists. In EDTF-Ruby, these are covered by the class `EDTF::Set`
and the `choice` attribute.

    > s = Date.edtf('{1667,1668, 1670..1672}')
    > s.choice?
    => false
    > s.choice!
    > s.edtf
    => "[1667, 1668, 1670..1672]"

As you can see above, EDTF-Ruby remembers which parts of the set were
specified as a range; ranges are however enumerated for membership tests:

    > s.include?(Date.edtf('1669'))
    => false
    > s.include?(Date.edtf('1671'))
    => true

Even though we're still aware that the year 1671 was is not directly an
element of the set:

    > s.length
    => 3

When in doubt, you can always map the set to an array. This will also
enumerate all ranges:

    > s.map(&:year)
    => [1667, 1668, 1670, 1671, 1672] # when enumerated there are 5 elements

EDTF sets also feature an `#earlier?` and `#later?` attribute:

    > s.earlier?
    => false
    > s.earlier!
    > s.edtf
    => "[..1667, 1668, 1670..1672]"


### Decades and Centuries

The EDTF specification supports so called masked precision strings to define
decades or centuries. EDTF-Ruby maps these to dedicated intervals which
always cover 10 or 100 years, respectively.

    > d = Date.edtf!('196x')
    => 196x
    > d.class
    => EDTF::Decade
    > d.class
    => EDTF::Decade
    > d.min
    => Fri, 01 Jan 1960
    > d.max
    => Wed, 31 Dec 1969
    > d.map(&:year)
    => [1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969]

### Seasons

Finally, EDTF covers seasons. Again, EDTF-Ruby provides a dedicated class
for this. Note that EDTF does not make any assumption about the specifics
(which months etc.) of the season and you don't have to either; however
EDTF-Ruby defines method aliases which allow you to access the seasons
by the names spring, summer, autumn (or fall), and winter, respectively.
You can also use the more neutral taxonomy of first, second, third,
fourth.

    > w = Date.edtf!('2003-24')
    > w.winter?
    => true
    > s = w.succ
    > s.spring?
    => true
    > s.year
    => 2004
    > s.min
    => Mon, 01 Mar 2004
    > s.max
    => Mon, 31 May 2004
    > s.to_a.length
    => 92
    005:0> w.to_a.length
    => 91

As you can see, spring 2004 lasted one day longer than winter 2003 (note
that spring and winter here do not relate to the astronomical seasons
but strictly to three month periods).

Of course you can print seasons to EDTF strings, too. Finally, seasons can
be uncertain/approximate.

    > s.edtf
    => "2004-21"
    > s.approximate!.edtf
    => "2004-21"


For additional features, please take a look at the documentation or the
extensive list of rspec examples.


Contributing
------------
The EDTF-Ruby source code is [hosted on GitHub](https://github.com/inukshuk/edtf-ruby).
You can check out a copy of the latest code using Git:

    $ git clone https://github.com/inukshuk/edtf-ruby.git

To get started, generate the parser and run all tests:

    $ cd edtf-ruby
    $ bundle install
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
