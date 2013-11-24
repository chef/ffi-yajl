#!/usr/bin/env ruby

if !defined?(RUBY_ENGINE) || RUBY_ENGINE == 'ruby' || RUBY_ENGINE == 'rbx'
  require 'mkmf'
  require 'rbconfig'

  # the customer is always right, ruby is always compiled to be stupid
  $CFLAGS = ENV['CFLAGS'] if ENV['CFLAGS']
  $LDFLAGS = ENV['LDFLAGS'] if ENV['LDFLAGS']
  RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

  # except if you're doing an unoptimized gcc install we're going to help you out a bit
  if RbConfig::MAKEFILE_CONFIG['CC'] =~ /gcc|clang/
    $CFLAGS << " -O3" unless $CFLAGS[/-O\d/]
    # how many people realize that -Wall is a compiler-specific flag???
    # apparently not many based on reading lots of shitty extconf.rb's out there
    $CFLAGS << " -Wall"
  end

  # yajl_complete_parse is only in >= 2.0
  libyajl2_ok = have_library("yajl", "yajl_complete_parse", [ "yajl/yajl_parse.h" ])
else
  # always install libyajl2 on Jruby
  # FIXME: get the conditional mkmf stuff to work on Jruby
  libyajl2_ok = false
end

prefix=File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

unless libyajl2_ok
  ENV['CFLAGS'] = RbConfig::expand "$(CFLAGS)"
  ENV['LDFLAGS'] = RbConfig::expand "$(LDFLAGS)"
  ENV['CC'] = RbConfig::MAKEFILE_CONFIG['CC']
  system "wget -O yajl-2.0.1.tar.gz http://github.com/lloyd/yajl/tarball/2.0.1" or raise "wget failed"
  system "tar xvf yajl-2.0.1.tar.gz" or raise "tar xvf failed"
  Dir.chdir "lloyd-yajl-f4b2b1a" or raise "chdir failed"
  system "./configure --prefix=#{prefix} > /tmp/libyajl.out" or raise "configure failed"
  system "make install >> /tmp/libyajl.out" or raise "make install failed"
  Dir.chdir ".."
end

dir_config 'libyajl2'

File.open("Makefile", "w") do |mf|
  mf.puts "# Dummy makefile for non-mri rubies"
  mf.puts "all install::\n"
end

