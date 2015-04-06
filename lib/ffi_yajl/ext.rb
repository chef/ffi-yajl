require 'rubygems'

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'
require 'ffi_yajl/map_library_name'

module FFI_Yajl
  extend FFI_Yajl::MapLibraryName

  dlopen_yajl_library

  class Parser
    require 'ffi_yajl/ext/parser'
    include FFI_Yajl::Ext::Parser
  end

  class Encoder
    require 'ffi_yajl/ext/encoder'
    include FFI_Yajl::Ext::Encoder
  end
end
