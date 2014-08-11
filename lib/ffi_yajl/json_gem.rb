
# JSON compatibility layer, largely plagarized from yajl-ruby

require 'ffi_yajl' unless defined?(FFI_Yajl::Parser)

module JSON
  class JSONError < StandardError; end unless defined?(JSON::JSONError)
  class GeneratorError < JSONError; end unless defined?(JSON::GeneratorError)
  class ParserError < JSONError; end unless defined?(JSON::ParserError)

  def self.generate(obj, opts=nil)
    opts ||= {}
    options_map = {}
    if opts.has_key?(:indent)
      options_map[:pretty] = true
      options_map[:indent] = opts[:indent]
    end
    FFI_Yajl::Encoder.encode(obj, options_map)
  rescue FFI_Yajl::EncodeError => e
    raise JSON::GeneratorError, e.message
  end

  def self.pretty_generate(obj, opts=nil)
    opts ||= {}
    options_map = {}
    options_map[:pretty] = true
    options_map[:indent] = opts[:indent] if opts.has_key?(:indent)
    FFI_Yajl::Encoder.encode(obj, options_map).chomp
  rescue FFI_Yajl::EncodeError => e
    raise JSON::GeneratorError, e.message
  end

  def self.dump(obj, io=nil, *args)
    FFI_Yajl::Encoder.encode(obj, io)
  rescue FFI_Yajl::EncodeError => e
    raise JSON::GeneratorError, e.message
  end

  def self.default_options
    @default_options ||= {:symbolize_keys => false}
  end

  def self.parse(str, opts=JSON.default_options)
    FFI_Yajl::Parser.parse(str, opts)
  rescue FFI_Yajl::ParseError => e
    raise JSON::ParserError, e.message
  end

  def self.load(input, *args)
    FFI_Yajl::Parser.parse(input, default_options)
  rescue FFI_Yajl::ParseError => e
    raise JSON::ParserError, e.message
  end
end

class Array
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class Hash
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class Fixnum
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class Float
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class String
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class TrueClass
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class FalseClass
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class NilClass
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class Date
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class Time
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

class DateTime
  def to_json(*opts, &block)
    FFI_Yajl::Encoder.encode(self, *opts)
  end
end

module ::Kernel
  def JSON(object, opts = {})
    if object.respond_to? :to_s
      JSON.parse(object.to_s, JSON.default_options.merge(opts))
    else
      JSON.generate(object,opts)
    end
  end
end

class Object
  unless defined?(ActiveSupport)
    def to_json(*args, &block)
      "\"#{to_s}\""
    end
  end
end
