require 'mkmf'

# the customer is always right, ruby is always compiled to be stupid
$CFLAGS = ENV['CFLAGS'] if ENV['CFLAGS']
$LDFLAGS = ENV['LDFLAGS'] if ENV['LDFLAGS']
RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

# search our gem root first to pick up libyajl2 that we vendored
gem_root = File.expand_path(File.join(File.dirname(__FILE__), "../../../.."))
$CFLAGS = "-I#{gem_root}/include -L#{gem_root}/lib #{$CFLAGS}"
$LDFLAGS = "-L#{gem_root}/lib #{$CFLAGS}"

puts gem_root
puts $CFLAGS
puts $LDFLAGS

# except if you're doing an unoptimized gcc install we're going to help you out a bit
if RbConfig::MAKEFILE_CONFIG['CC'] =~ /gcc|clang/
  $CFLAGS << " -O3" unless $CFLAGS[/-O\d/]
  # how many people realize that -Wall is a compiler-specific flag???
  # apparently not many based on reading lots of shitty extconf.rb's out there
  $CFLAGS << " -Wall"
end

$LDFLAGS << " -lyajl"

dir_config 'encoder'

create_makefile 'ffi_yajl/ext/encoder'
