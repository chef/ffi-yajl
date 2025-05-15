$:.unshift(File.dirname(__FILE__) + "/lib")
require "ffi_yajl/version"

Gem::Specification.new do |s|
  s.name             = "ffi-yajl"
  s.version          = FFI_Yajl::VERSION
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.license          = "MIT"
  s.summary          = "Ruby FFI wrapper around YAJL 2.x"
  s.description      = s.summary
  s.author           = "Lamont Granquist"
  s.email            = "lamont@chef.io"
  s.homepage         = "http://github.com/chef/ffi-yajl"

  s.required_ruby_version = ">= 3.1"

  s.add_dependency "libyajl2", ">= 2.1"

  s.bindir       = "bin"
  s.executables  = %w{ ffi-yajl-bench }
  s.require_path = "lib"
  s.files        = %w{ LICENSE } + Dir.glob( "{bin,lib,ext}/**/*", File::FNM_DOTMATCH ).reject { |f| File.directory?(f) }

  s.add_dependency "yajl"

  s.add_development_dependency "cookstyle", "~> 8.1"

  s.platform = Gem::Platform.new(%w{universal mingw-ucrt})

end
