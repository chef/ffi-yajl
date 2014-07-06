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

def found_libyajl2
  find_header('yajl/yajl_tree.h') && find_library('yajl', 'yajl_complete_parse')
end

if !windows? && !found_libyajl2
  puts "libyajl2 not embedded in libyajl2-gem, searching for system libraries..."

  HEADER_DIRS = [
    # FIXME: embedded version number in Homebrew path will change
    "/usr/local/Cellar/yajl/2.1.0/include", # Homebrew (yick)
    "/opt/local/include",                   # MacPorts
    "/usr/local/include",                   # /usr/local
    RbConfig::CONFIG['includedir'],         # Ruby
    "/usr/include",                         # (default)
  ]

  LIB_DIRS = [
    "/opt/local/lib",                       # MacPorts
    "/usr/local/lib",                       # /usr/local + Homebrew
    RbConfig::CONFIG['libdir'],             # Ruby
    "/usr/lib",                             # (default)
  ]

  # add --with-yajl-dir, --with-yajl-include, --with-yajl-lib
  dir_config('yajl', HEADER_DIRS, LIB_DIRS)

  if !found_libyajl2
    abort "libyajl2 is missing.  please install libyajl2"
  end
end

dir_config 'parser'

create_makefile 'ffi_yajl/ext/parser'
