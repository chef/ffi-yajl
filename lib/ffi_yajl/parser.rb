
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
      @opts = opts
    end

    def parse(str)
      # initialization that we can do in pure ruby
      yajl_opts = {}

      # XXX: bug-compat with ruby-yajl
      return nil if str == ""

      # call either the ext or ffi hook
      do_yajl_parse(str, yajl_opts)
    end
  end
end
