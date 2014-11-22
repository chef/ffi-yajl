
#
# Precedence:
#
# - The FORCE_FFI_YAJL env var takes precedence over everything else, the user
#   theoretically knows best
# - Java always gets ffi because jruby only supports ffi
# - There is a conflict between loading libyajl 1.x and 2.x in the same VM
#   process (on a fundamental basis, simply guru medidate about how the
#   c-symbols work if you load both libs).  For some reason the ffi interface
#   seems to work fine sometimes (i'm not sure how) so we fall back to that--
#   this is much more likely to be converted into a raise than to have the warn
#   dropped, so don't bother asking for that.
# - Then we try the c-ext and rescue into ffi that fails
#
if ENV['FORCE_FFI_YAJL'] == "ext"
  require 'ffi_yajl/ext'
elsif ENV['FORCE_FFI_YAJL'] == "ffi"
  require 'ffi_yajl/ffi'
elsif RUBY_PLATFORM == "java"
  require 'ffi_yajl/ffi'
elsif defined?(Yajl)
  warn "the ffi-yajl and yajl-ruby gems have incompatible C libyajl libs and should not be loaded in the same Ruby VM"
  warn "falling back to ffi which might work (or might not, no promises)"
  require 'ffi_yajl/ffi'
else
  begin
    require 'ffi_yajl/ext'
  rescue LoadError
    warn "failed to load the ffi-yajl c-extension, falling back to ffi interface"
    require 'ffi_yajl/ffi'
  end
end
