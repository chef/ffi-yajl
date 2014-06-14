require 'rubygems'

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'
require 'ffi'
require 'libyajl2'
begin
  require 'fiddle'
rescue LoadError
end
begin
  require 'dl'
rescue LoadError
end

module FFI_Yajl
  # FIXME: DRY with ffi_yajl/ffi.rb
  libname = ::FFI.map_library_name("yajl")
  libpath = File.expand_path(File.join(Libyajl2.opt_path, libname))
  libpath.gsub!(/dylib/, 'bundle')
  libpath = ::FFI.map_library_name("yajl") unless File.exist?(libpath)
  if defined?(Fiddle) && Fiddle.respond_to?(:dlopen)
    ::Fiddle.dlopen(libpath)
  elsif defined?(DL) && DL.respond_to?(:dlopen)
    ::DL.dlopen(libpath)
  else
    extend ::FFI::Library
    ffi_lib libpath
  end

  class Parser
    require 'ffi_yajl/ext/parser'
    include FFI_Yajl::Ext::Parser
  end

  class Encoder
    require 'ffi_yajl/ext/encoder'
    include FFI_Yajl::Ext::Encoder
  end
end

