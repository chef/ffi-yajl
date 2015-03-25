
require 'ffi_yajl/platform'

module FFI_Yajl
  module MapLibraryName
    include FFI_Yajl::Platform
    def map_library_name
      # this is the right answer for the internally built libyajl on windows
      return "libyajl.so" if windows?

      # this is largely copied from the FFI.map_library_name algorithm, we most likely need
      # the windows code eventually to support not using the embedded libyajl2-gem
      libprefix =
        case RbConfig::CONFIG['host_os'].downcase
        when /mingw|mswin/
          ''
        when /cygwin/
          'cyg'
        else
          'lib'
        end
      libsuffix =
        case RbConfig::CONFIG['host_os'].downcase
        when /darwin/
          'bundle'
        when /linux|bsd|solaris|sunos/
          'so'
        when /mingw|mswin|cygwin/
          'dll'
        else
          # Punt and just assume a sane unix (i.e. anything but AIX)
          'so'
        end
      libprefix + "yajl" + ".#{libsuffix}"
    end
  end
end
