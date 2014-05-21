require 'rubygems'

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'
require 'dl'
require 'ffi'
require 'libyajl2'


module FFI_Yajl
  class Parser
    # FIXME: DRY with ffi_yajl/ffi.rb
    libname = ::FFI.map_library_name("yajl")
    libpath = File.expand_path(File.join(Libyajl2.opt_path, libname))
    libpath.gsub!(/dylib/, 'bundle')
    ::DL.dlopen(libpath)
    require 'ffi_yajl/ext/parser'
    include FFI_Yajl::Ext::Parser
  end

  class Encoder
    # FIXME: DRY with ffi_yajl/ffi.rb
    libname = ::FFI.map_library_name("yajl")
    libpath = File.expand_path(File.join(Libyajl2.opt_path, libname))
    libpath.gsub!(/dylib/, 'bundle')
    ::DL.dlopen(libpath)
    require 'ffi_yajl/ext/encoder'
    include FFI_Yajl::Ext::Encoder
  end
end

