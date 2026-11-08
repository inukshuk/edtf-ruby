Changelog
=========

5.0.0 (unreleased)
------------------
EDTF-Ruby 5.0 switches from the EDTF draft syntax to ISO 8601-2;
see [UPGRADING.md](UPGRADING.md) for the API changes and migration.

* Reads all of ISO 8601-2 levels 0–2; writes ISO 8601-2 only.
* Still reads the draft syntax (legacy syntax), with a grammar of its own;
  `legacy: false` or `strict: true` turn it off.
* New frozen types, all periods with plain dates as bounds;
  no core patches: `EDTF()` converts strings, parse results, dates and times.
* `EDTF::Parser` returns plain parse results and takes the options
  `level:`, `extensions:`, `legacy:`, `strict:` and `max_year_digits:`.
* `19XX` and `196X` are read as centuries and decades
  (`centuries: false` to turn off).
* Reversed intervals and years beyond 100 digits are rejected.
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
