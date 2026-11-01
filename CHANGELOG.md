Changelog
=========

5.0.0 (unreleased)
------------------
EDTF-Ruby 5.0 switches from the EDTF draft syntax to ISO 8601-2,
modelled on EDTF.js.
See [UPGRADING.md](UPGRADING.md) for how to upgrade from 4.x.

* Output is ISO 8601-2 only
  (`%`, qualification from the left, `..` and empty interval ends, `X`, `Z`).
* New types, all frozen periods with plain dates as `begin` and `end`:
  `EDTF::Date < Date`, `EDTF::DateTime < Time`, `EDTF::Decade`,
  `EDTF::Century`, `EDTF::Season`, `EDTF::Interval`,
  `EDTF::Set` (one of) and `EDTF::List` (all of).
* `with` returns modified copies; there are no bang! methods.
* No core patches: `Date.edtf`, `Date#edtf`, `Range#edtf` and the
  EDTF methods on Ruby's `Date` and `DateTime` are gone.
  `EDTF()` converts strings, parse results, Ruby dates and times.
* `EDTF::Parser` returns parse results (frozen hashes in the structure
  of EDTF.js) with levels; `EDTF()` builds objects from them,
  also when read back from JSON.
* Unspecified digits widen a date's bounds; `XXXX` is a date with an
  unspecified year (`EDTF::Unknown` is gone).
* Seasons 21–41 with their bounds; southern seasons step in calendar order.
* Date-times without an offset are floating, never in the system's zone.
* `==` means the same period; `eql?` and `hash` the same EDTF expression.
* `to_s` and `as_json` return the EDTF string.
* ActiveSupport is no longer a dependency; EDTF-Ruby works with it.

4.1.1
-----
* Spaces in sets (`[1864 ..]`) are reported as legacy syntax.

4.1.0
-----
A bridge release to prepare for 5.0.

* Deprecation warnings for legacy syntax (enable `Warning[:deprecated]`).
* `EDTF.legacy?` finds strings in legacy syntax.
* `EDTF()` converts strings, Ruby dates and times to EDTF objects.
* `Date#with` returns a copy with a new precision or qualifiers.
* `Date.edtf` and `Date.edtf!` are deprecated; use `EDTF.parse`.
