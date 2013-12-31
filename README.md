
[![Build Status](https://travis-ci.org/lamont-granquist/ffi-yajl.png)](https://travis-ci.org/lamont-granquist/ffi-yajl)  [![Code Climate](https://codeclimate.com/github/lamont-granquist/ffi-yajl.png)](https://codeclimate.com/github/lamont-granquist/ffi-yajl)

TODO:

- switching from curling yajl2 sources to using git submodule
- fix rake compile blowing up on libyajl2
- block ruby 1.8.7 from using c extension (segfault)
- test both ffi and ext on platforms that support both (MRI, rbx)

BUILD NOTES:
  - building libyajl2 requires 'apt-get install cmake' on ubuntu, but note
    that 'apt-get install libyajl2' will be better

