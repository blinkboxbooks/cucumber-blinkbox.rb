# Changelog

## 0.3.2 ([#13](https://git.mobcastdev.com/TEST/cucumber-blinkbox/pull/13) 2014-12-10 17:03:42)

Add a general require's file to avoid having projects need to declare requiring each module individually if applicable

Patch

Gives projects that currently require each module explicitly an option to pull them all in by calling `require cucumber/blinkbox`

## 0.3.1 ([#12](https://git.mobcastdev.com/TEST/cucumber-blinkbox/pull/12) 2014-08-11 17:18:58)

Default Content-Type header behaviour

### Patch

- Get the RSpec tests runnable under CI
- Default to a Content-Type when not specified, otherwise take the user defined value

## 0.3.0 ([#11](https://git.mobcastdev.com/TEST/cucumber-blinkbox/pull/11) 2014-08-06 16:41:20)

Enable SSL cert loading

### New Feature

- [CP-1708](http://jira.blinkbox.local/jira/browse/CP-1708) Forces HTTPClient to use the OpenSSL default certificate file in order for it to act in a similar fashion to HTTParty and other gems (for testing).

## 0.2.3 ([#9](https://git.mobcastdev.com/TEST/cucumber-blinkbox/pull/9) 2014-06-30 17:06:16)

Update to artifactory spec

### Improvements

- Moved to using Artifactory.

## 0.2.2 (2014-04-03)

### Clean up

- Cleaned up custom html formatter: removed unnecessary #after_table_row which is overridden later on in the formatter file

## 0.2.1 (2014-03-26 14:17)

### Bug fix

- `URI.join` doesn't work well with colons in paths, so swapped to `File.join` (which joins with `/` even on windows)

## 0.2.0 (2014-03-06 16:19)

### New Features

- The `data_for_a` method allows to specify the number of objects to return.


## 0.1.0 (2014-03-05 13:37)

### New Features

- Added a custom `Cucumber::Blinkbox::Formatter::Html` formatter based on Alex's custom HTML formatter, as it is shared between numerous projects.

## 0.0.3 (2014-03-03 13:43)

### Bug Fixes

- Removed dependency on `Blinkbox::Test::Api::Json` from `validate_list_order`.

## 0.0.2 (2014-02-26 09:54)

### New Features

- The 'warn_only' option in `validate_attribute` allows you to specify that some expections are allowed to fail. This will output a warning message, but allows us to test services which are not currently up to the new standard.
