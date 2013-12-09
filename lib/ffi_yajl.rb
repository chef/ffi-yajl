require 'rubygems'
require 'ffi'

module FFI_Yajl
  class ParseError < StandardError; end
  class EncodeError < StandardError; end

  class Encoder
    attr_accessor :opts

    def encode(obj)
      # initialization that we can do in pure ruby
      yajl_gen_opts = {}

      yajl_gen_opts[:yajl_gen_validate_utf8] = true
      yajl_gen_opts[:yajl_gen_beautify] = false
      yajl_gen_opts[:yajl_gen_indent_string] = " "

      if opts[:pretty]
        yajl_gen_opts[:yajl_gen_beautify] = true
        yajl_gen_opts[:yajl_gen_indent_string] = opts[:indent] ? opts[:indent] : "  "
      end

      # call either the ext or ffi hook
      str = do_yajl_encode(obj, yajl_gen_opts)
      str.force_encoding('UTF-8') if defined? Encoding
    end

    def self.encode(obj, *args)
      new(*args).encode(obj)
    end

    def initialize(opts = {})
      @opts = opts
    end

    def self.raise_error_for_status(status)
      case status
      when 1 # yajl_gen_keys_must_be_strings
        raise FFI_Yajl::EncodeError, "YAJL internal error: attempted use of non-string object as key"
      when 2 # yajl_max_depth_exceeded
        raise FFI_Yajl::EncodeError, "Max nesting depth exceeded"
      when 3 # yajl_gen_in_error_state
        raise FFI_Yajl::EncodeError, "YAJL internal error: a generator function (yajl_gen_XXX) was called while in an error state"
      when 4 # yajl_gen_generation_complete
        raise FFI_Yajl::EncodeError, "YAJL internal error: attempted to encode to an already-complete document"
      when 5 # yajl_gen_invalid_number
        raise FFI_Yajl::EncodeError, "Invalid number: cannot encode Infinity, -Infinity, or NaN"
      when 6 # yajl_gen_no_buf
        raise FFI_Yajl::EncodeError, "YAJL internal error: yajl_gen_get_buf was called, but a print callback was specified, so no internal buffer is available"
      else
        raise FFI_Yajl::EncodeError, "Unknown YAJL Error, please report this as a bug"
      end
    end

    if ENV['FORCE_FFI_YAJL'] == "ext"
      require 'ffi_yajl/ext'
      include FFI_Yajl::Ext::Encoder
    elsif ENV['FORCE_FFI_YAJL'] == "ffi"
      require 'ffi_yajl/ffi'
      include FFI_Yajl::FFI::Encoder
    elsif defined?(Yajl)
      # on Linux yajl-ruby and non-FFI ffi_yajl conflict
      require 'ffi_yajl/ffi'
      include FFI_Yajl::FFI::Encoder
    else
      begin
        require 'ffi_yajl/ext'
        include FFI_Yajl::Ext::Encoder
      rescue LoadError
        require 'ffi_yajl/ffi'
        include FFI_Yajl::FFI::Encoder
      end
    end
  end

  class Parser
    attr_accessor :opts

    def self.parse(obj, *args)
      new(*args).parse(obj)
    end

    def initialize(opts = {})
      @opts = opts
    end

    def parse(str)
      # initialization that we can do in pure ruby
      yajl_opts = {}

      # call either the ext or ffi hook
      do_yajl_parse(str, yajl_opts)
    end

    if ENV['FORCE_FFI_YAJL'] == "ext"
      require 'ffi_yajl/ext'
      include FFI_Yajl::Ext::Parser
    elsif ENV['FORCE_FFI_YAJL'] == "ffi"
      require 'ffi_yajl/ffi'
      include FFI_Yajl::FFI::Parser
    elsif defined?(Yajl)
      # on Linux yajl-ruby and non-FFI ffi_yajl conflict
      require 'ffi_yajl/ffi'
      include FFI_Yajl::FFI::Parser
    else
      begin
        require 'ffi_yajl/ext'
        include FFI_Yajl::Ext::Parser
      rescue LoadError
        require 'ffi_yajl/ffi'
        include FFI_Yajl::FFI::Parser
      end
    end
  end
end

module FFI_Yajl
  extend ::FFI::Library

  libname = ::FFI.map_library_name("yajl")
  libpath = File.join(File.dirname(__FILE__), libname)

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
  attach_function :yajl_config, [:yajl_handle, :yajl_option, :int], :int

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

