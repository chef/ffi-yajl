require 'rubygems'
require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'
require 'ffi'
require 'libyajl2'

module FFI_Yajl
  # FIXME: DRY with ffi_yajl/ffi.rb
  libname = ::FFI.map_library_name("yajl")
  libpath = File.expand_path(File.join(Libyajl2.opt_path, libname))
  libpath.gsub!(/dylib/, 'bundle')
  libpath = ::FFI.map_library_name("yajl") unless File.exist?(libpath)

  begin
    # deliberately delayed require
    require 'fiddle'
    ::Fiddle.dlopen(libpath)
  rescue LoadError
    begin
      # deliberately delayed require
      require 'dl'
      ::DL.dlopen(libpath)
    rescue LoadError
      # deliberately delayed require
      require 'ffi_yajl/dlopen'
      FFI_Yajl::Dlopen.dlopen(libpath)
    end
  end

  class Parser
    require 'ffi_yajl/ext/parser'
    include FFI_Yajl::Ext::Parser
  end

  class Encoder
    require 'ffi_yajl/ext/encoder'
    include FFI_Yajl::Ext::Encoder
  end
end

