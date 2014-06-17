# Portions Originally Copyright (c) 2008-2011 Brian Lopez - http://github.com/brianmario
# See MIT-LICENSE

require 'rubygems'
require 'benchmark'
require 'stringio'
if !defined?(RUBY_ENGINE) || RUBY_ENGINE !~ /jruby/
  if ENV['FORCE_FFI_YAJL'] != 'ext'
    begin
      require 'yajl'
    rescue Exception
      puts "INFO: yajl-ruby not installed"
    end
  else
    puts "INFO: skipping yajl-ruby because we're using the C extension"
  end
else
  puts "INFO: skipping yajl-ruby on jruby"
end
require 'ffi_yajl'
begin
  require 'json'
rescue Exception
  puts "INFO: json gem not installed"
end
begin
  require 'psych'
rescue Exception
  puts "INFO: psych gem not installed"
end
begin
  require 'active_support'
rescue Exception
  puts "INFO: active_support gem not installed"
end
begin
  require 'oj'
rescue Exception
  puts "INFO: oj gem not installed"
end

module FFI_Yajl
  class Benchmark
    class Encode

      def run
        #filename = ARGV[0] || 'benchmark/subjects/ohai.json'
        filename = File.expand_path(File.join(File.dirname(__FILE__), "subjects", "ohai.json"))
        hash = File.open(filename, 'rb') { |f| FFI_Yajl::Parser.parse(f.read) }

        times = ARGV[1] ? ARGV[1].to_i : 1000
        puts "Starting benchmark encoding #{filename} #{times} times\n\n"
        ::Benchmark.bmbm { |x|

          x.report("FFI_Yajl::Encoder.encode (to a String)") {
            times.times {
              output = FFI_Yajl::Encoder.encode(hash)
            }
          }

          ffi_string_encoder = FFI_Yajl::Encoder.new
          x.report("FFI_Yajl::Encoder#encode (to a String)") {
            times.times {
              output = ffi_string_encoder.encode(hash)
            }
          }

          if defined?(Oj)
            x.report("Oj.dump (to a String)") {
              times.times {
                output = Oj.dump(hash)
              }
            }
          end

          if defined?(Yajl::Encoder)
            x.report("Yajl::Encoder.encode (to a String)") {
              times.times {
                output = Yajl::Encoder.encode(hash)
              }
            }

            io_encoder = Yajl::Encoder.new
            x.report("Yajl::Encoder#encode (to an IO)") {
              times.times {
                io_encoder.encode(hash, StringIO.new)
              }
            }

            string_encoder = Yajl::Encoder.new
            x.report("Yajl::Encoder#encode (to a String)") {
              times.times {
                output = string_encoder.encode(hash)
              }
            }
          end

          if defined?(JSON)
            x.report("JSON.generate") {
              times.times {
                JSON.generate(hash)
              }
            }
            x.report("JSON.fast_generate") {
              times.times {
                JSON.fast_generate(hash)
              }
            }
          end
          if defined?(Psych)
            x.report("Psych.to_json") {
              times.times {
                Psych.to_json(hash)
              }
            }
            if defined?(Psych::JSON::Stream)
              x.report("Psych::JSON::Stream") {
                times.times {
                  io = StringIO.new
                  stream = Psych::JSON::Stream.new io
                  stream.start
                  stream.push hash
                  stream.finish
                }
              }
            end
          end
#          if defined?(ActiveSupport::JSON)
#            x.report("ActiveSupport::JSON.encode") {
#              times.times {
#                ActiveSupport::JSON.encode(hash)
#              }
#            }
#          end
        }
      end
    end
  end

end
