
[![Build Status](https://travis-ci.org/chef/ffi-yajl.png)](https://travis-ci.org/chef/ffi-yajl)  [![Code Climate](https://codeclimate.com/github/chef/ffi-yajl.png)](https://codeclimate.com/github/chef/ffi-yajl)

# FFI YAJL

ffi-yajl is a Ruby adapter for the [yajl](http://lloyd.github.io/yajl/)
JSON parser/generator library. ffi-yajl supports multiple Ruby C
extension mechanisms, including both MRI native extensions and FFI in
order to be compatible with as many Ruby implementations as possible
while providing good performance where possible.

## How to Install

Install from the command-line:

```
gem install ffi-yajl
```

Or use a Gemfile:

```
gem 'ffi-yajl'
```

## Supported Ruby VMs:

* Ruby MRI 1.9.3/2.0.0/2.1.x/2.2.x
* rbx 2.2.x (possibly earlier)
* Jruby 1.7.x (possibly earlier)

Ruby 1.8.7 support was dropped in 2.2.0

## Supported Distros:

* Ubuntu 10.04 through 14.10
* Debian 7.x
* RHEL/CentOS/Oracle 5.x/6.x/7.x
* Solaris 9/10/11 (gcc, sun compiler untested)
* AIX 6.x/7.x (gcc or xlc)
* Windows 2008r2/2012 (and Win2k/2k3 and consumer versions should work)

## Basic Usage

Start by requiring it:

```ruby
require 'ffi_yajl'
```

You can encode and parse with class objects:

```ruby
options_hash = {}
json = FFI_Yajl::Encoder.encode( {"foo"=>["bar","baz"]}, options_hash )
hash = FFI_Yajl::Parser.parse( json, options_hash )
```

Or you can be more object oriented:

```ruby
options_hash = {}
encoder = FFI_Yajl::Encoder.new( options_hash )
json = encoder.encode( {"foo"=>["bar","baz"]} )
parser = FFI_Yajl::Parser.new( options_hash )
hash = parser.parse( json )
```

## Parser Options

* `:check_utf8`
* `:dont_validate_strings`
* `:symbolize_keys` (default = false):  JSON keys are parsed into symbols instead of strings.
* `:symbolize_names` (default = false):  Alias for `:symbolize_keys`.
* `:allow_trailing_garbage`
* `:allow_multiple_values`
* `:allow_partial_values`
* `:unique_key_checking` (default = false):  Will raise an exception if keys
   are repeated in hashes in the input JSON.  Without this, repeated keys will
   silently replace the previous key.

## Encoder Options

* `:pretty` (default = false):  Produces more human readable 'pretty' output.
* `:validate_utf8` (default = true):  Will raise an exception when trying to
   encode strings that are invalid UTF-8.  When set to false this still will
   produce valid UTF-8 JSON but will replace invalid characters.

## Forcing FFI or C Extension

You can set the environment variable `FORCE_FFI_YAJL` to `ext` or `ffi` to
control if the C extension or FFI bindings are used.

## Yajl Library Packaging

This library prefers to use the embedded yajl 2.x C library packaged in the
libyajl2 gem.  In order to use the operating system yajl library (which must be
yajl 2.x) the environment variable `USE_SYSTEM_LIBYAJL2` can be set before
installing or bundling libyajl2.  This will force the libyajl2 gem to skip
compiling its embedded library and the ffi-yajl gem will fallback to using the
system yajl library.

## No JSON Gem Compatiblity layer

This library does not offer a feature to patch `#to_json` methods into all
the ruby classes similarly to the JSON gem or yajl-ruby's `yajl/json_gem`
compatibility API.  The differences in encoding between the JSON gem and the
Yajl C library can produce different output on different systems and makes
testing brittle.  Such a feature will not be included.  It was removed in
this pull request and could be easily extracted to its own gem (we have
no interest in maintaining that gem):

https://github.com/chef/ffi-yajl/pull/47/files

## Why This Instead of X?

yajl is the only JSON library we've found that has error messages that
meet our requirements. The stdlib json gem and oj (at the time we
started this project) have error messages like "invalid token at byte
1234," which are probably fine for server use, but in
[chef](https://github.com/chef/chef) we frequently deal with
user-written JSON documents, which means we need a good user experience
when encountering malformed JSON.

We previously used brianmario's
[yajl-ruby](https://github.com/brianmario/yajl-ruby) project, but we
wanted to be able to fallback to using FFI bindings to the C code (so we
could support non-MRI rubies) and we also needed some bug fixes in
yajl2, but the maintainer wasn't able to devote enough time to the
project to make these updates in a timeframe that worked for us.

## Thanks

This was initially going to be a clean rewrite of an ffi ruby wrapper around
yajl2, but as it progressed more and more code was pulled in from brianmario's
existing yajl-ruby gem, particularly all the c extension code, lots of specs
and the benchmarks.  And the process of writing this would have been much more
difficult without being able to draw heavily from already solved problems in
yajl-ruby.

## License

Given that this draws heavily from the yajl-ruby sources, and could be
considered a derivative work, the MIT License from that project has been
preserved and this source code has deliberately not been dual licensed under
Chef's typical Apache License.  See the
[LICENSE](https://github.com/chef/ffi-yajl/blob/master/LICENSE) file in this
project.
