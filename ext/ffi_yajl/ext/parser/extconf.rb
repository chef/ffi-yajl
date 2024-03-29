# rubocop:disable Style/GlobalVars
require "mkmf"
require "rubygems"
require "libyajl2"

RbConfig::MAKEFILE_CONFIG["CC"] = ENV["CC"] if ENV["CC"]

# pick up the vendored libyajl2 out of the libyajl2 gem
$CFLAGS = "-I#{Libyajl2.include_path} #{$CFLAGS}"
$LDFLAGS = "-L#{Libyajl2.opt_path} #{$LDFLAGS}"

# remove "-Wl,--no-undefined" flag if existent to allow for loading with dlopen
$LDFLAGS.slice!("-Wl,--no-undefined")

puts $CFLAGS
puts $LDFLAGS

# except if you're doing an unoptimized gcc install we're going to help you out a bit
if RbConfig::MAKEFILE_CONFIG["CC"] =~ /gcc|clang/
  $CFLAGS << " -O3" unless $CFLAGS[/-O\d/]
  # how many people realize that -Wall is a compiler-specific flag???
  # apparently not many based on reading lots of shitty extconf.rb's out there
  $CFLAGS << " -Wall"
end

def windows?
  !!(RUBY_PLATFORM =~ /mswin|mingw|cygwin|windows/)
end

def macos?
  !!(RUBY_PLATFORM =~ /darwin/)
end

def clang?
  cc_version = `#{RbConfig.expand("$(CC) --version")}`
  cc_version.match?(/clang/i)
end

# XCode 14 warns if `-Wl,-undefined dynamic_lookup` is specified, and as
# a result Ruby interpreters compiled under XCode 14 no longer specify
# this flag by default in DLDFLAGS. Let's specify the list of dynamic symbols
# here to avoid compilation failures.
if clang? && macos?
  symfile = File.join(__dir__, '../dlopen/yajl.sym')
  dynamic_symbols = File.readlines(symfile)
  dynamic_symbols.each do |sym|
    $DLDFLAGS << " -Wl,-U,#{sym.strip}"
  end
end

if windows?
  # include our libyajldll.a definitions on windows in the libyajl2 gem
  $libs = "#{$libs} -lyajldll"
end

# NOTE: find_library has the side effect of adding -lyajl to the flags which we are deliberately
# avoiding doing with the libyajl2-gem (allowing it to be lazily loaded with dlopen)
if !windows? && !find_header("yajl/yajl_tree.h")
  puts "libyajl2 headers not found in libyajl2-gem, searching for system libraries..."

  HEADER_DIRS = [
    "/opt/local/include",                   # MacPorts
    "/usr/local/include",                   # /usr/local
    RbConfig::CONFIG["includedir"],         # Ruby
    "/usr/include",                         # (default)
  ].freeze

  LIB_DIRS = [
    "/opt/local/lib",                       # MacPorts
    "/usr/local/lib",                       # /usr/local + Homebrew
    RbConfig::CONFIG["libdir"],             # Ruby
    "/usr/lib",                             # (default)
  ].freeze

  # add --with-yajl-dir, --with-yajl-include, --with-yajl-lib
  dir_config("yajl", HEADER_DIRS, LIB_DIRS)

  # here we use find_library in order to deliberately link with -lyajl as a useful side-effect
  unless find_header("yajl/yajl_tree.h") && find_library("yajl", "yajl_complete_parse")
    abort "libyajl2 is missing.  please install libyajl2"
  end
end

dir_config "parser"

create_makefile "ffi_yajl/ext/parser"
