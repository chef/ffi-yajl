require 'rubygems'

require 'ffi_yajl/encoder'
require 'ffi_yajl/parser'
require 'ffi'
require 'libyajl2'

module FFI_Yajl
  # FIXME: DRY with ffi_yajl/ffi.rb
  # FIXME: extract map_library_name from FFI and stop requiring it at the top level
  #        so that the C-library can be installed without FFI
  libname = ::FFI.map_library_name("yajl")
  # awful windows patch, but there is an open issue to entirely replace FFI.map_library_name already
  libname = "libyajl.so" if libname == "yajl.dll"
  libpath = File.expand_path(File.join(Libyajl2.opt_path, libname))
  libpath.gsub!(/dylib/, 'bundle')
  libpath = ::FFI.map_library_name("yajl") unless File.exist?(libpath)

  #
  # FFS, what exactly was so wrong with DL.dlopen that ruby had to get rid of it???
  #

  def self.try_fiddle_dlopen(libpath)
    require 'fiddle'
    if defined?(Fiddle) && Fiddle.respond_to?(:dlopen)
      ::Fiddle.dlopen(libpath)
      true
    else
      false
    end
  rescue LoadError
    return false
  end

  def self.try_dl_dlopen(libpath)
    require 'dl'
    if defined?(DL) && DL.respond_to?(:dlopen)
      ::DL.dlopen(libpath)
      true
    else
      false
    end
  rescue LoadError
    return false
  end

  def self.try_ffi_dlopen(libpath)
    require 'ffi'
    require 'rbconfig'
    extend ::FFI::Library
    ffi_lib 'dl'
    attach_function 'dlopen', :dlopen, [:string, :int], :void
    if  RbConfig::CONFIG['host_os'] =~ /linux/i
      dlopen libpath, 0x102  # linux: RTLD_GLOBAL | RTLD_NOW
    else
      dlopen libpath, 0
    end
    true
  rescue LoadError
    return false
  end

  unless try_fiddle_dlopen(libpath) || try_dl_dlopen(libpath) || try_ffi_dlopen(libpath)
    raise "cannot find dlopen vi Fiddle, DL or FFI, what am I supposed to do?"
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
