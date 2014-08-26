# ChangeLog

## master (unreleased)

### New features

### Changes

### Bugs fixed

## 1.1.0 (08/26/2014)

### New features

* Support encoding Date, Time and DateTime objects

### Bugs fixed

* Fixed Rubinius on at least Ubuntu 14.04 and Mac
* [**Lennart Brinkmann**](https://github.com/lebrinkma):
  remove `-Wl,--no-undefined` if ruby mkmf.rb adds it in the CFLAGS because we do not directly link against `-lyajl`

## 1.0.2 (08/09/2014)

### Bugs fixed

* fixed opts chaining issue in the encoder that was breaking pretty printing in knife
* changed default :allow_comments to true (considered a regression against yajl-ruby compatibility)

## 1.0.1 (07/17/2014)

* No ChangeLog entries for this version or earlier, check the commit logs

