
if ENV['FORCE_FFI_YAJL'] == "ext"
  require 'ffi_yajl/ext'
elsif ENV['FORCE_FFI_YAJL'] == "ffi" || defined?(Yajl)
  # can't dynlink our libyajl2 c-ext and Yajl's libyajl1 c-ext into the same binary
  require 'ffi_yajl/ffi'
else
  begin
    require 'ffi_yajl/ext'
  rescue LoadError
    require 'ffi_yajl/ffi'
  end
end
