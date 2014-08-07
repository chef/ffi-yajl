
module FFI_Yajl
  class ParseError < StandardError; end
  class Parser
    attr_accessor :stack, :key_stack, :key, :finished

    attr_accessor :opts

    #
    # stack used to build up our complex object
    #
    def stack
      @stack ||= Array.new
    end

    #
    # stack to keep track of keys as we create nested hashes
    #
    def key_stack
      @key_stack ||= Array.new
    end

    def self.parse(obj, *args)
      new(*args).parse(obj)
    end

    def initialize(opts = {})
      @opts = opts ? opts.dup : {}
      # JSON gem uses 'symbolize_names' and ruby-yajl supports this as well
      @opts[:symbolize_keys] = true if @opts[:symbolize_names]
    end

    def parse(str)
      # initialization that we can do in pure ruby
      yajl_opts = {}

      if @opts[:check_utf8] == false && @opts[:dont_validate_strings] == false
        raise ArgumentError, "options check_utf8 and dont_validate_strings are both false which conflict"
      end
      if @opts[:check_utf8] == true && @opts[:dont_validate_strings] == true
        raise ArgumentError, "options check_utf8 and dont_validate_strings are both true which conflict"
      end

      yajl_opts[:yajl_allow_comments]         = true

      if @opts.key?(:allow_comments)
        yajl_opts[:yajl_allow_comments]       = @opts[:allow_comments]
      end

      yajl_opts[:yajl_dont_validate_strings]  = (@opts[:check_utf8] == false || @opts[:dont_validate_strings])
      yajl_opts[:yajl_allow_trailing_garbage] = @opts[:allow_trailing_garbage]
      yajl_opts[:yajl_allow_multiple_values]  = @opts[:allow_multiple_values]
      yajl_opts[:yajl_allow_partial_values]   = @opts[:allow_partial_values]

      # XXX: bug-compat with ruby-yajl
      return nil if str == ""

      if str.respond_to?(:read)
        str = str.read()
      end

      # call either the ext or ffi hook
      do_yajl_parse(str, yajl_opts)
    end
  end
end
