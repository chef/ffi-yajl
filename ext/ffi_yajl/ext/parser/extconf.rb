require 'mkmf'
require 'rubygems'
require 'libyajl2'

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

# pick up the vendored libyajl2 out of the libyajl2 gem
$CFLAGS = "-I#{Libyajl2.include_path} #{$CFLAGS}"
$LDFLAGS = "-L#{Libyajl2.opt_path} #{$LDFLAGS}"

puts $CFLAGS
puts $LDFLAGS

# except if you're doing an unoptimized gcc install we're going to help you out a bit
if RbConfig::MAKEFILE_CONFIG['CC'] =~ /gcc|clang/
  $CFLAGS << " -O3" unless $CFLAGS[/-O\d/]
  # how many people realize that -Wall is a compiler-specific flag???
  # apparently not many based on reading lots of shitty extconf.rb's out there
  $CFLAGS << " -Wall"
end

def windows?
  !!(RUBY_PLATFORM =~ /mswin|mingw|windows/)
end

if windows?
  # include our libyajldll.a definitions on windows in the libyajl2 gem
  $libs = "#{$libs} -lyajldll"
end

dir_config 'parser'

create_makefile 'ffi_yajl/ext/parser'
