
begin
  require 'ffi_yajl/encoder/ext'
rescue LoadError
  require 'ffi_yajl/encoder/ffi'
end

