require 'rubygems'

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'
require 'ffi'
require 'libyajl2'
begin
  require 'fiddle'
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
  else
    # deliberately convoluted delayed require here to avoid deprecation
    # warning from requiring dl
    require 'dl'
    if defined?(DL) && DL.respond_to?(:dlopen)
      ::DL.dlopen(libpath)
    else
      raise "cannot find dlopen in either DL or Fiddle, cannot proceed"
    end
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

