
if ENV['FORCE_FFI_YAJL'] == "ext"
  require 'ffi_yajl/ext'
elsif ENV['FORCE_FFI_YAJL'] == "ffi" || defined?(Yajl) || RUBY_VERSION.to_f < 1.9
  # - can't dynlink our libyajl2 c-ext and Yajl's libyajl1 c-ext into the same binary
  # - c-extension segfaults on ruby 1.8.7
  require 'ffi_yajl/ffi'
else
  begin
    require 'ffi_yajl/ext'
  rescue LoadError
    require 'ffi_yajl/ffi'
  end
end
