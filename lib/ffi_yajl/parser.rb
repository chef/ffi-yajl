
module FFI_Yajl
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

    if ENV['FORCE_FFI_YAJL'] == "ffi" || defined?(Yajl)
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
