
module FFI_Yajl
  class ParseError < StandardError; end
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
  end
end
