#!/usr/bin/env ruby

require 'rbconfig'

cflags = ENV['CFLAGS']
ldflags = ENV['LDFLAGS']
cc = ENV['CC']

# use the CC that ruby was compiled with by default
cc ||= RbConfig::MAKEFILE_CONFIG['CC']
cflags ||= ""
ldflags ||= ""

# then ultimately default back to gcc
cc ||= "gcc"

# FIXME: add more compilers with default options
if cc =~ /gcc|clang/
  cflags << " -O3" unless cflags =~ /-O\d/
  cflags << " -Wall"
end

if !defined?(RUBY_ENGINE) || RUBY_ENGINE == 'ruby' || RUBY_ENGINE == 'rbx'
  require 'mkmf'

  # yajl_complete_parse is only in >= 2.0
  libyajl2_ok = have_library("yajl", "yajl_complete_parse", [ "yajl/yajl_parse.h" ]) && have_func("yajl_complete_parse")
else
  # always install libyajl2 on Jruby
  # FIXME: get the conditional mkmf stuff to work on Jruby
  libyajl2_ok = false
end

prefix=File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

#dir_config 'libyajl2'

if libyajl2_ok
  File.open("Makefile", "w") do |mf|
    mf.puts "# Dummy makefile when we don't build the library"
    mf.puts "all install::\n"
  end
else
  ENV['CFLAGS'] = cflags
  ENV['LDFLAGS'] = ldflags
  ENV['CC'] = cc
  system("cp -rf #{File.expand_path(File.join(File.dirname(__FILE__), "vendored"))} .") unless File.exists?("vendored")

  File.open("Makefile", "w") do |mf|
    mf.puts "# Makefile for building vendored libyajl2"
    mf.puts "CFLAGS = #{ENV['CFLAGS']}"
    mf.puts "LDFLAGS = #{ENV['LDFLAGS']}"
    mf.puts "CC = #{ENV['CC']}\n"
    mf.puts "all install::"
    mf.puts "\tcd vendored && ./configure --prefix=#{prefix}"
    mf.puts "\tcd vendored && make install"
    mf.puts "\tcp -f vendored/build/yajl-2.0.5/lib/libyajl.so .\n"
  end
end

