require 'rubygems'

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'

module FFI_Yajl
  class Parser
    require 'ffi_yajl/ext/parser'
    include FFI_Yajl::Ext::Parser
  end

  class Encoder
    require 'ffi_yajl/ext/encoder'
    include FFI_Yajl::Ext::Encoder
  end
end

