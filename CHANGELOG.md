# Changelog

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