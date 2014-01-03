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

unless libyajl2_ok
  ENV['CFLAGS'] = cflags
  ENV['LDFLAGS'] = ldflags
  ENV['CC'] = cc
  puts "CFLAGS = #{ENV['CFLAGS']}"
  puts "LDFLAGS = #{ENV['LDFLAGS']}"
  puts "CC = #{ENV['CC']}"
  system "wget -O yajl-2.0.1.tar.gz http://github.com/lloyd/yajl/tarball/2.0.1" or raise "wget failed"
  system "tar xvf yajl-2.0.1.tar.gz" or raise "tar xvf failed"
  Dir.chdir "lloyd-yajl-f4b2b1a" or raise "chdir failed"
  system "./configure --prefix=#{prefix} > /tmp/libyajl.out" or raise "configure failed"
  system "make install >> /tmp/libyajl.out" or raise "make install failed"
  Dir.chdir ".."
end

#dir_config 'libyajl2'

File.open("Makefile", "w") do |mf|
  mf.puts "# Dummy makefile for non-mri rubies"
  mf.puts "all install::\n"
end

