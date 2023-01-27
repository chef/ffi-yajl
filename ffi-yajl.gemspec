$LOAD_PATH.unshift File.expand_path("#{__dir__}/lib")
require 'ffi_yajl/version'

Gem::Specification.new do |s|
  s.name             = 'ffi-yajl'
  s.version          = FFI_Yajl::VERSION
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.license          = "MIT"
  s.summary          = "Ruby FFI wrapper around YAJL 2.x"
  s.description      = s.summary
  s.author           = "Lamont Granquist"
  s.email            = "lamont@chef.io"
  s.homepage         = "http://github.com/chef/ffi-yajl"

  s.required_ruby_version = ">= 2.2"

  s.add_dependency "libyajl2", ">= 1.2"

  s.bindir       = "bin"
  s.executables  = %w{ ffi-yajl-bench }
  s.require_path = "lib"
  s.files        = Dir["LICENSE", "{bin,lib,ext}/**/*"].reject { |f| File.directory?(f) }

  if ENV['FFI_YAJL_BUILD_JAVA']
    s.platform = "universal-java"

    # XXX: after the libyajl2-gem, we don't need to fork the
    # extensions so can we simplify the gemspecs now?
    # gemspec.extensions = %w{ ext/libyajl2/extconf.rb }

    s.add_dependency "ffi", "~> 1.5"
  else
    s.platform = Gem::Platform::RUBY
    s.extensions = Dir["ext/ffi_yajl/ext/**/extconf.rb"]
  end
end
