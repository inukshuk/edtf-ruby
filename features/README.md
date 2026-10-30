EDTF-Ruby Cucumber Features
===========================
The Cucumber features test what the parser accepts at each EDTF level,
in both syntax variants (ISO 8601-2 and the legacy draft),
and with the non-standard extensions.

| Tag           | Meaning                                              |
|---------------|------------------------------------------------------|
| `@level<n>`   | EDTF / ISO 8601-2 level 0, 1 or 2                    |
| `@legacy`     | Legacy mode only: draft syntax, EDTF-Ruby extensions |
| `@ext-<name>` | Non-standard extension, enabled by default           |
| `@wip`        | Valid input that is not supported yet                |

Usage
-----
By default, runs everything except `@wip`:

    bundle exec cucumber

To run only the `@wip` tests use (this will fail if any of them pass):

    bundle exec cucumber -p wip

To run only the tests with a given tag, e.g. `@legacy`:

    bundle exec cucumber --tags @legacy
