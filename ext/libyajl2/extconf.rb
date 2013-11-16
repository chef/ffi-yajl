#!/usr/bin/env ruby

require 'mkmf'
require 'rbconfig'

## the customer is always right, ruby is always compiled to be stupid
$CFLAGS = ENV['CFLAGS'] if ENV['CFLAGS']
$LDFLAGS = ENV['LDFLAGS'] if ENV['LDFLAGS']
RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

## except if you're doing an unoptimized gcc install we're going to help you out a bit
#if RbConfig::MAKEFILE_CONFIG['CC'] =~ /gcc|clang/
#  $CFLAGS << " -O3" unless $CFLAGS[/-O\d/]
#end

pkg_config('yajl')

# yajl_tree.h is only in >= 2.0
have_header("yajl/yajl_tree.h") || find_header("yajl/yajl_tree.h", "/usr/local/include")

# yajl_complete_parse is only in >= 2.0
libyajl2_ok = have_library("yajl", "yajl_complete_parse", [ "yajl/yajl_parse.h" ])

prefix=File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

unless libyajl2_ok
  system "wget -O yajl-2.0.1.tar.gz http://github.com/lloyd/yajl/tarball/2.0.1"
  system "tar xvf yajl-2.0.1.tar.gz"
  Dir.chdir "lloyd-yajl-f4b2b1a"
  system "./configure --prefix=#{prefix} > /tmp/libyajl.out"
  system "make install >> /tmp/libyajl.out"
  Dir.chdir ".."
end

create_makefile("dummy")

File.open("Makefile", "w") do |mf|
  mf.puts "# Dummy makefile for non-mri rubies"
  mf.puts "all install::\n"
end

##LIBYAJL_VERSION="2.0.1"
##SUPPORT_LIB = FFI.map_library_name("libyajl2-#{LIBYAJL_VERSION}")
##
##prefix=File.expand_path(File.join(ENV['RUBYARCHDIR'], ".."))
##
##end
#
