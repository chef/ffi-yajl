
if ENV['FORCE_FFI_YAJL'] == "ext"
  require 'ffi_yajl/ext'
elsif ENV['FORCE_FFI_YAJL'] == "ffi" || defined?(Yajl)
  # on Linux yajl-ruby and non-FFI ffi_yajl conflict
  require 'ffi_yajl/ffi'
else
  begin
    require 'ffi_yajl/ext'
  rescue LoadError
    require 'ffi_yajl/ffi'
  end
end
