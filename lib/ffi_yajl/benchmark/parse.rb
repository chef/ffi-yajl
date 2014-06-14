require 'rubygems'
require 'benchmark'
require 'yaml'
require 'yajl'
require 'ffi_yajl'
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
begin
  require 'json'
rescue LoadError
end
begin
  require 'psych'
rescue LoadError
end
begin
  require 'active_support'
rescue LoadError
end
begin
  require 'oj'
rescue LoadError
end

class FFI_Yajl::Benchmark::Parse

  def run
    filename = File.expand_path(File.join(File.dirname(__FILE__), "subjects", "item.json"))
    json = File.new(filename, 'r')
    json_str = json.read

    times = ARGV[1] ? ARGV[1].to_i : 10_000
    puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
    Benchmark.bmbm { |x|
      x.report {
        puts "FFI_Yajl::Parser.parse (from a String)"
        times.times {
          FFI_Yajl::Parser.parse(json_str)
        }
      }
#      ffi_parser = FFI_Yajl::Parser.new
#      x.report {
#        puts "FFI_Yajl::Parser#parse (from a String)"
#        times.times {
#          json.rewind
#          ffi_parser.parse(json.read)
#        }
#      }
      if defined?(Yajl::Parser)
        x.report {
          puts "Yajl::Parser.parse (from a String)"
          times.times {
            Yajl::Parser.parse(json_str)
          }
        }
        io_parser = Yajl::Parser.new
        io_parser.on_parse_complete = lambda {|obj|} if times > 1
        x.report {
          puts "Yajl::Parser#parse (from an IO)"
          times.times {
            json.rewind
            io_parser.parse(json)
          }
        }
        string_parser = Yajl::Parser.new
        string_parser.on_parse_complete = lambda {|obj|} if times > 1
        x.report {
          puts "Yajl::Parser#parse (from a String)"
          times.times {
            json.rewind
            string_parser.parse(json_str)
          }
        }
      end
      if defined?(Oj)
        x.report {
          puts "Oj.load"
          times.times {
            json.rewind
            Oj.load(json.read)
          }
        }
      end
      if defined?(JSON)
        x.report {
          puts "JSON.parse"
          times.times {
            json.rewind
            JSON.parse(json.read, :max_nesting => false)
          }
        }
      end
      if defined?(ActiveSupport::JSON)
        x.report {
          puts "ActiveSupport::JSON.decode"
          times.times {
            json.rewind
            ActiveSupport::JSON.decode(json.read)
          }
        }
      end
      x.report {
        puts "YAML.load (from an IO)"
        times.times {
          json.rewind
          YAML.load(json)
        }
      }
      x.report {
        puts "YAML.load (from a String)"
        times.times {
          YAML.load(json_str)
        }
      }
      if defined?(Psych)
        x.report {
          puts "Psych.load (from an IO)"
          times.times {
            json.rewind
            Psych.load(json)
          }
        }
        x.report {
          puts "Psych.load (from a String)"
          times.times {
            Psych.load(json_str)
          }
        }
      end
    }
    json.close

  end
end

