# ChangeLog

## master (unreleased)

### New features

### Changes

### Bugs fixed

## 1.2.0 (10/09/2014)

### Changes

* Encoding Object will no longer blindly call .to_json().  It will first check if the Object supports a .to_json() method
and if it does not it will call .to_s().  This prevents NoSuchMethod errors when not using the JSON gem.  

### Bugs fixed

* C extension was broken on windows due to libyajl.so being renamed to yajl.dll which has been reverted in
  libyajl2-gem.
* Change Config to RbConfig for FFI-based dlopen for non-DL/non-Fiddle fallback.

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

