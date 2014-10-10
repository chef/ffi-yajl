require 'rubygems'

require 'libyajl2'
require 'ffi'

module FFI_Yajl
  extend ::FFI::Library

  libname = ::FFI.map_library_name("yajl")
  # XXX: need to replace ::FFI.map_library_name here as well
  libname = "libyajl.so" if libname == "yajl.dll"
  libpath = File.expand_path(File.join(Libyajl2.opt_path, libname))
  libpath.gsub!(/dylib/, 'bundle')

  if File.file?(libpath)
    # use our vendored version of libyajl2 if we find it installed
    ffi_lib libpath
  else
    ffi_lib 'yajl'
  end

  class YajlCallbacks < ::FFI::Struct
    layout :yajl_null, :pointer,
      :yajl_boolean, :pointer,
      :yajl_integer, :pointer,
      :yajl_double, :pointer,
      :yajl_number, :pointer,
      :yajl_string, :pointer,
      :yajl_start_map, :pointer,
      :yajl_map_key, :pointer,
      :yajl_end_map, :pointer,
      :yajl_start_array, :pointer,
      :yajl_end_array, :pointer
  end

  enum :yajl_status, [
    :yajl_status_ok,
    :yajl_status_client_canceled,
    :yajl_status_insufficient_data,
    :yajl_status_error,
  ]

# FFI::Enums are slow, should remove the rest
#  enum :yajl_gen_status, [
#    :yajl_gen_status_ok,
#    :yajl_gen_keys_must_be_strings,
#    :yajl_max_depth_exceeded,
#    :yajl_gen_in_error_state,
#    :yajl_gen_generation_complete,
#    :yajl_gen_invalid_number,
#    :yajl_gen_no_buf,
#  ]

  enum :yajl_option, [
    :yajl_allow_comments, 0x01,
    :yajl_dont_validate_strings, 0x02,
    :yajl_allow_trailing_garbage, 0x04,
    :yajl_allow_multiple_values, 0x08,
    :yajl_allow_partial_values, 0x10,
  ]

  enum :yajl_gen_option, [
    :yajl_gen_beautify, 0x01,
    :yajl_gen_indent_string, 0x02,
    :yajl_gen_print_callback, 0x04,
    :yajl_gen_validate_utf8, 0x08,
  ]

  typedef :pointer, :yajl_handle
  typedef :pointer, :yajl_gen

  # yajl uses unsinged char *'s consistently
  typedef :pointer, :ustring_pointer
  typedef :string, :ustring

  # const char *yajl_status_to_string (yajl_status code)
  attach_function :yajl_status_to_string, [ :yajl_status ], :string
  # yajl_handle yajl_alloc(const yajl_callbacks * callbacks, yajl_alloc_funcs * afs, void * ctx)
  attach_function :yajl_alloc, [:pointer, :pointer, :pointer], :yajl_handle
  # void yajl_free (yajl_handle handle)
  attach_function :yajl_free, [:yajl_handle], :void
  # yajl_status yajl_parse (yajl_handle hand, const unsigned char *jsonText, unsigned int jsonTextLength)
  attach_function :yajl_parse, [:yajl_handle, :ustring, :uint], :yajl_status
  # yajl_status yajl_parse_complete (yajl_handle hand)
  attach_function :yajl_complete_parse, [:yajl_handle], :yajl_status
  # unsigned char *yajl_get_error (yajl_handle hand, int verbose, const unsigned char *jsonText, unsigned int jsonTextLength)
  attach_function :yajl_get_error, [:yajl_handle, :int, :ustring, :int], :ustring
  # void yajl_free_error (yajl_handle hand, unsigned char *str)
  attach_function :yajl_free_error, [:yajl_handle, :ustring], :void

  #
  attach_function :yajl_config, [:yajl_handle, :yajl_option, :varargs], :int

  attach_function :yajl_gen_config, [:yajl_gen, :yajl_gen_option, :varargs], :int

  # yajl_gen yajl_gen_alloc (const yajl_alloc_funcs *allocFuncs)
  attach_function :yajl_gen_alloc, [:pointer], :yajl_gen
  # yajl_gen yajl_gen_alloc2 (const yajl_print_t callback, const yajl_gen_config *config, const yajl_alloc_funcs *allocFuncs, void *ctx)
  # attach_function :yajl_gen_alloc2, [:pointer, :pointer, :pointer, :pointer], :yajl_gen
  # void  yajl_gen_free (yajl_gen handle)
  attach_function :yajl_gen_free, [:yajl_gen], :void

  attach_function :yajl_gen_integer, [:yajl_gen, :long_long], :int
  attach_function :yajl_gen_double, [:yajl_gen, :double], :int
  attach_function :yajl_gen_number, [:yajl_gen, :ustring, :int], :int
  attach_function :yajl_gen_string, [:yajl_gen, :ustring, :int], :int
  attach_function :yajl_gen_null, [:yajl_gen], :int
  attach_function :yajl_gen_bool, [:yajl_gen, :int], :int
  attach_function :yajl_gen_map_open, [:yajl_gen], :int
  attach_function :yajl_gen_map_close, [:yajl_gen], :int
  attach_function :yajl_gen_array_open, [:yajl_gen], :int
  attach_function :yajl_gen_array_close, [:yajl_gen], :int
  # yajl_gen_status yajl_gen_get_buf (yajl_gen hand, const unsigned char **buf, unsigned int *len)
  attach_function :yajl_gen_get_buf, [:yajl_gen, :pointer ,:pointer], :int
  # void yajl_gen_clear (yajl_gen hand)
  attach_function :yajl_gen_clear, [:yajl_gen], :void

end

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'

module FFI_Yajl
  class Parser
    require 'ffi_yajl/ffi/parser'
    include FFI_Yajl::FFI::Parser
  end

  class Encoder
    require 'ffi_yajl/ffi/encoder'
    include FFI_Yajl::FFI::Encoder
  end
end
