# Change Log

## [2.2.2](https://github.com/chef/ffi-yajl/tree/2.2.2) (2015-07-15)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/2.2.1...2.2.2)

**Merged pull requests:**

- fix uninitialized constant errors [\#69](https://github.com/chef/ffi-yajl/pull/69) ([lamont-granquist](https://github.com/lamont-granquist))

## [2.2.1](https://github.com/chef/ffi-yajl/tree/2.2.1) (2015-07-13)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/2.2.0...2.2.1)

**Closed issues:**

- typo? require 'ffi-yajl' [\#63](https://github.com/chef/ffi-yajl/issues/63)

**Merged pull requests:**

- Lcg/more cops [\#68](https://github.com/chef/ffi-yajl/pull/68) ([lamont-granquist](https://github.com/lamont-granquist))
- fix superclass mismatch on rbx in c ext [\#67](https://github.com/chef/ffi-yajl/pull/67) ([lamont-granquist](https://github.com/lamont-granquist))
- Lcg/rubocop [\#66](https://github.com/chef/ffi-yajl/pull/66) ([lamont-granquist](https://github.com/lamont-granquist))
- Fix require in readme [\#65](https://github.com/chef/ffi-yajl/pull/65) ([thommay](https://github.com/thommay))
- Fix uninitialized instance variable when using ext [\#64](https://github.com/chef/ffi-yajl/pull/64) ([danielsdeleo](https://github.com/danielsdeleo))
- Fix superclass mismatch for class StringIO [\#62](https://github.com/chef/ffi-yajl/pull/62) ([kou](https://github.com/kou))
- Suppress assigned but unused variable warning [\#61](https://github.com/chef/ffi-yajl/pull/61) ([kou](https://github.com/kou))
- Suppress circular require warnings [\#60](https://github.com/chef/ffi-yajl/pull/60) ([kou](https://github.com/kou))
- Suppress method redefined warnings [\#59](https://github.com/chef/ffi-yajl/pull/59) ([kou](https://github.com/kou))
- fix parse error in travis.yml [\#58](https://github.com/chef/ffi-yajl/pull/58) ([AaronLasseigne](https://github.com/AaronLasseigne))

## [2.2.0](https://github.com/chef/ffi-yajl/tree/2.2.0) (2015-04-30)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/2.1.0...2.2.0)

**Merged pull requests:**

- change :validate\_utf8=false to still emit utf8 [\#57](https://github.com/chef/ffi-yajl/pull/57) ([lamont-granquist](https://github.com/lamont-granquist))
- emit token that failed utf-8 validation [\#56](https://github.com/chef/ffi-yajl/pull/56) ([lamont-granquist](https://github.com/lamont-granquist))

## [2.1.0](https://github.com/chef/ffi-yajl/tree/2.1.0) (2015-04-20)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/2.0.0...2.1.0)

**Implemented enhancements:**

- write c extension for dlopen [\#23](https://github.com/chef/ffi-yajl/issues/23)
- make ffi gem optional [\#22](https://github.com/chef/ffi-yajl/issues/22)

**Merged pull requests:**

- add :unique\_key\_checking flag to parser [\#55](https://github.com/chef/ffi-yajl/pull/55) ([lamont-granquist](https://github.com/lamont-granquist))
- add copyright notices [\#54](https://github.com/chef/ffi-yajl/pull/54) ([lamont-granquist](https://github.com/lamont-granquist))
- add ruby 2.2.0 track latest rbx [\#53](https://github.com/chef/ffi-yajl/pull/53) ([lamont-granquist](https://github.com/lamont-granquist))
- add DLopen extension [\#52](https://github.com/chef/ffi-yajl/pull/52) ([lamont-granquist](https://github.com/lamont-granquist))
- Lcg/add appveyor config [\#50](https://github.com/chef/ffi-yajl/pull/50) ([lamont-granquist](https://github.com/lamont-granquist))
- Remove ffi gem as a hard dependency [\#49](https://github.com/chef/ffi-yajl/pull/49) ([lamont-granquist](https://github.com/lamont-granquist))
- support encoding StringIOs [\#19](https://github.com/chef/ffi-yajl/pull/19) ([lamont-granquist](https://github.com/lamont-granquist))

## [2.0.0](https://github.com/chef/ffi-yajl/tree/2.0.0) (2015-03-17)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/1.4.0...2.0.0)

**Fixed bugs:**

- cygwin impossible to use [\#36](https://github.com/chef/ffi-yajl/issues/36)

**Merged pull requests:**

- Removing JSON gem compatibility layer [\#47](https://github.com/chef/ffi-yajl/pull/47) ([lamont-granquist](https://github.com/lamont-granquist))
- use travis containers [\#45](https://github.com/chef/ffi-yajl/pull/45) ([lamont-granquist](https://github.com/lamont-granquist))
- Lcg/fix windows check [\#44](https://github.com/chef/ffi-yajl/pull/44) ([lamont-granquist](https://github.com/lamont-granquist))

## [1.4.0](https://github.com/chef/ffi-yajl/tree/1.4.0) (2015-02-17)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/1.3.1...1.4.0)

**Merged pull requests:**

- Lcg/fix windows check [\#43](https://github.com/chef/ffi-yajl/pull/43) ([lamont-granquist](https://github.com/lamont-granquist))
- add note about license [\#40](https://github.com/chef/ffi-yajl/pull/40) ([lamont-granquist](https://github.com/lamont-granquist))
- Update README w/ basic use and "why this" [\#39](https://github.com/chef/ffi-yajl/pull/39) ([danielsdeleo](https://github.com/danielsdeleo))
- Lcg/invalid utf8 [\#38](https://github.com/chef/ffi-yajl/pull/38) ([lamont-granquist](https://github.com/lamont-granquist))
- include status code for Unknown Error [\#37](https://github.com/chef/ffi-yajl/pull/37) ([glensc](https://github.com/glensc))

## [1.3.1](https://github.com/chef/ffi-yajl/tree/1.3.1) (2014-11-25)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/1.3.0...1.3.1)

**Merged pull requests:**

- Lcg/object as key [\#34](https://github.com/chef/ffi-yajl/pull/34) ([lamont-granquist](https://github.com/lamont-granquist))

## [1.3.0](https://github.com/chef/ffi-yajl/tree/1.3.0) (2014-11-23)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/1.2.0...1.3.0)

**Fixed bugs:**

- ffi-yajl slowness on Windows with Chef [\#26](https://github.com/chef/ffi-yajl/issues/26)
- ffi-yajl should parse bare objects for ruby-yajl compat [\#16](https://github.com/chef/ffi-yajl/issues/16)
- parsing nil needs to not coredump [\#15](https://github.com/chef/ffi-yajl/issues/15)
- keys need to be '\#to\_s''d as a last resort [\#14](https://github.com/chef/ffi-yajl/issues/14)
- Can't install gem with cygwin  [\#10](https://github.com/chef/ffi-yajl/issues/10)
- Segfault when executing `JSON.parse 1` in rails console [\#2](https://github.com/chef/ffi-yajl/issues/2)

**Merged pull requests:**

- Lcg/encoding keys [\#33](https://github.com/chef/ffi-yajl/pull/33) ([lamont-granquist](https://github.com/lamont-granquist))
- Lcg/parser bugs [\#32](https://github.com/chef/ffi-yajl/pull/32) ([lamont-granquist](https://github.com/lamont-granquist))
- fix minor typo [\#31](https://github.com/chef/ffi-yajl/pull/31) ([glensc](https://github.com/glensc))
- Cygwin detection https://github.com/opscode/ffi-yajl/issues/10 [\#30](https://github.com/chef/ffi-yajl/pull/30) ([electrawn](https://github.com/electrawn))
- add better ext-vs-ffi logic [\#29](https://github.com/chef/ffi-yajl/pull/29) ([lamont-granquist](https://github.com/lamont-granquist))
- windows isn't compatible with libyajl \<= 1.1.0 [\#28](https://github.com/chef/ffi-yajl/pull/28) ([lamont-granquist](https://github.com/lamont-granquist))

## [1.2.0](https://github.com/chef/ffi-yajl/tree/1.2.0) (2014-10-10)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/1.1.0...1.2.0)

**Fixed bugs:**

- Only fall back to `.to\_json` if object supports it [\#24](https://github.com/chef/ffi-yajl/issues/24)
- Config -\> RbConfig deprecation warning on every execution of knife. [\#17](https://github.com/chef/ffi-yajl/issues/17)

**Merged pull requests:**

- fix libnames for windows [\#27](https://github.com/chef/ffi-yajl/pull/27) ([lamont-granquist](https://github.com/lamont-granquist))
- If an object does not have .to\_json, we no longer try to call it [\#25](https://github.com/chef/ffi-yajl/pull/25) ([tyler-ball](https://github.com/tyler-ball))
- Lcg/rbconfig [\#13](https://github.com/chef/ffi-yajl/pull/13) ([lamont-granquist](https://github.com/lamont-granquist))

## [1.1.0](https://github.com/chef/ffi-yajl/tree/1.1.0) (2014-08-26)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/1.0.2...1.1.0)

**Fixed bugs:**

- Fix Rubinius [\#6](https://github.com/chef/ffi-yajl/issues/6)

**Merged pull requests:**

- fixing rbx via ffi [\#12](https://github.com/chef/ffi-yajl/pull/12) ([lamont-granquist](https://github.com/lamont-granquist))
- extconf.rb: remove "-Wl,--no-undefined" from ldflags [\#11](https://github.com/chef/ffi-yajl/pull/11) ([lebrinkma](https://github.com/lebrinkma))
- add datetime encoding [\#9](https://github.com/chef/ffi-yajl/pull/9) ([lamont-granquist](https://github.com/lamont-granquist))

## [1.0.2](https://github.com/chef/ffi-yajl/tree/1.0.2) (2014-08-10)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/1.0.1...1.0.2)

**Merged pull requests:**

- ensure opts hash is never nil [\#5](https://github.com/chef/ffi-yajl/pull/5) ([lamont-granquist](https://github.com/lamont-granquist))
- Lcg/json opts [\#4](https://github.com/chef/ffi-yajl/pull/4) ([lamont-granquist](https://github.com/lamont-granquist))
- change allow\_comment default to true [\#3](https://github.com/chef/ffi-yajl/pull/3) ([lamont-granquist](https://github.com/lamont-granquist))

## [1.0.1](https://github.com/chef/ffi-yajl/tree/1.0.1) (2014-07-17)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/chef/ffi-yajl/tree/1.0.0) (2014-07-16)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.2.1...1.0.0)

## [0.2.1](https://github.com/chef/ffi-yajl/tree/0.2.1) (2014-07-16)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.2.0...0.2.1)

## [0.2.0](https://github.com/chef/ffi-yajl/tree/0.2.0) (2014-06-17)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.1.7...0.2.0)

## [0.1.7](https://github.com/chef/ffi-yajl/tree/0.1.7) (2014-06-13)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.1.6...0.1.7)

## [0.1.6](https://github.com/chef/ffi-yajl/tree/0.1.6) (2014-06-05)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.1.5...0.1.6)

## [0.1.5](https://github.com/chef/ffi-yajl/tree/0.1.5) (2014-05-21)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.1.4...0.1.5)

**Fixed bugs:**

- can't install on Mac OS X [\#1](https://github.com/chef/ffi-yajl/issues/1)

## [0.1.4](https://github.com/chef/ffi-yajl/tree/0.1.4) (2014-05-21)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.1.3...0.1.4)

## [0.1.3](https://github.com/chef/ffi-yajl/tree/0.1.3) (2014-05-20)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.1.2...0.1.3)

## [0.1.2](https://github.com/chef/ffi-yajl/tree/0.1.2) (2014-05-07)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.1.1...0.1.2)

## [0.1.1](https://github.com/chef/ffi-yajl/tree/0.1.1) (2014-05-06)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.1.0...0.1.1)

## [0.1.0](https://github.com/chef/ffi-yajl/tree/0.1.0) (2014-05-06)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.0.4...0.1.0)

## [0.0.4](https://github.com/chef/ffi-yajl/tree/0.0.4) (2014-01-13)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.0.3...0.0.4)

## [0.0.3](https://github.com/chef/ffi-yajl/tree/0.0.3) (2014-01-13)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.0.2...0.0.3)

## [0.0.2](https://github.com/chef/ffi-yajl/tree/0.0.2) (2014-01-11)
[Full Changelog](https://github.com/chef/ffi-yajl/compare/0.0.1...0.0.2)

## [0.0.1](https://github.com/chef/ffi-yajl/tree/0.0.1) (2014-01-09)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*