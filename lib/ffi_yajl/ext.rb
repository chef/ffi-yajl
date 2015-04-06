require 'rubygems'

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'
require 'libyajl2'
require 'ffi_yajl/map_library_name'
require 'ffi_yajl/ext/dlopen'

module FFI_Yajl
  extend FFI_Yajl::MapLibraryName

  extend FFI_Yajl::Ext::Dlopen

  libname = map_library_name
  libpath = File.expand_path(File.join(Libyajl2.opt_path, libname))

  dlopen(libpath)

  class Parser
    require 'ffi_yajl/ext/parser'
    include FFI_Yajl::Ext::Parser
  end

  class Encoder
    require 'ffi_yajl/ext/encoder'
    include FFI_Yajl::Ext::Encoder
  end
end
