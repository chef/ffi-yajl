require 'rubygems'

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'

module FFI_Yajl
  class ParseError < StandardError; end
  class EncodeError < StandardError; end
end

