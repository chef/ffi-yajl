
module FFI_Yajl
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
      str = do_yajl_encode(obj, yajl_gen_opts, opts)
      str.force_encoding('UTF-8') if defined? Encoding
      str
    end

    def self.encode(obj, *args)
      new(*args).encode(obj)
    end

    def initialize(opts = {})
      @opts = opts
      @opts ||= {}
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
  end
end
