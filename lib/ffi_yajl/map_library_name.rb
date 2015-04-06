require 'libyajl2'
require 'ffi_yajl/platform'
require 'ffi_yajl/ext/dlopen'

module FFI_Yajl
  module MapLibraryName
    include FFI_Yajl::Platform
    include FFI_Yajl::Ext::Dlopen

    def library_names
      case RbConfig::CONFIG['host_os'].downcase
      when /mingw|mswin/
        [ "libyajl.so", "yajl.dll" ]
      when /cygwin/
        [ "libyajl.so", "cygyajl.dll" ]
      when /darwin/
        [ "libyajl.bundle", "libyajl.dylib" ]
      else
        [ "libyajl.so" ]
      end
    end

    def expanded_library_names
      library_names.map do |libname|
        pathname = File.expand_path(File.join(Libyajl2.opt_path, libname))
        pathname if File.file?(pathname)
      end.compact
    end

    def dlopen_yajl_library
      found = false
      ( expanded_library_names + library_names ).each do |libname|
        begin
          dlopen(libname)
          found = true
          break
        rescue ArgumentError
        end
      end
      raise "cannot find yajl library for platform" unless found
    end

    def ffi_open_yajl_library
      found = false
      expanded_library_names.each do |libname|
        begin
          ffi_lib libname
          found = true
        rescue
        end
      end
      ffi_lib 'yajl' unless found
    end
  end
end
