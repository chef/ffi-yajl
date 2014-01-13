require 'rubygems'

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'

#unless RUBY_VERSION.to_f >= 1.9
#  # segfaults on ruby 1.8 and this is an exceedingly low priority to fix, use ffi instead
#  raise NotImplementedError, "The C-extension is disabled on Ruby 1.8"
#end

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

