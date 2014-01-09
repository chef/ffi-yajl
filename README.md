
[![Build Status](https://travis-ci.org/lamont-granquist/ffi-yajl.png)](https://travis-ci.org/lamont-granquist/ffi-yajl)  [![Code Climate](https://codeclimate.com/github/lamont-granquist/ffi-yajl.png)](https://codeclimate.com/github/lamont-granquist/ffi-yajl)

## TODO

- test both ffi and ext on platforms that support both (MRI, rbx)

## BUILD NOTES

- building libyajl2 requires 'apt-get install cmake' on ubuntu, but note
  that 'apt-get install libyajl2' will be better

## KNOWN BUGS

- 'rake compile' broken on mac, only tested to work on linux (ubuntu)
- C Extension segfaults on ruby 1.8.7, so the ffi mode is forced for RUBY_VERSION < 1.9
