# ChangeLog

## master (unreleased)

### New features

### Changes

### Bugs fixed

## 2.1.0 (04/20/2015)

### New features

* StringIOs are now encoded to strings
* Added `:unique_key_checking` flag to parser that will raise on repeated hash keys
  (commonly edit mistakes in long JSON documents).

### Changes

* Includes its own dlopen extension
* C extension should operation without ffi

## 2.0.0 (03/17/2015)

### Changes

* Dropped the `ffi-yajl/json_gem` monkeypatch compatibility layer completely.  The deprecation
  warning has been in there for months now and all the work to remove it from chef and ohai
  has been done in all the latest releases.

## 1.4.0 (02/17/2015)

### New features

* Implement :validate_utf8 (on by default) which can be set to false to suppress validation

### Bugs fixed

* [**Elan Ruusamäe**](https://github.com/glensc):
  include status code for Unknown Error
* [**Tyler Vann-Campbell**](https://github.com/lrdcasimir)
  Fix check for windows? on cygwin and get dll name right
* Correctly throw useful invalid UTF-8 error exception

## 1.3.1 (11/24/2014)

### Bugs fixed

* fixes using Objects as Hash keys

## 1.3.0 (11/22/2014)

### New features

* [**Jason Potkanski**](https://github.com/electrawn):
  Cygwin detection

### Changes

* warn on fallback to ffi when yajl-ruby is loaded (ffi-yajl and yajl-ruby use incompatible yajl c-libs)
* warn when we don't use the c ext on MRI or RBX (ffi is currently much slower than the c-ext)
* further bumped the libyajl2-gem pin to ~> 1.2 (required for the cygwin users)
* fix minimum libyajl2-gem version to ~> 1.1 (ffi-yajl >= 1.2.0 with libyajl2-gem 1.0 fails on windows)
* allow the c-ext to load on ruby 1.8.7

### Bugs fixed

* fixes using Arrays and Hashes (and true/false/nil) as Hash keys
* fixes bare object parsing in issue #2 and #6
* fixes parsing nil object to not coredump the MRI ruby VM (issue #15)

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

