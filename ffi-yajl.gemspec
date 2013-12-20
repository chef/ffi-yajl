$:.unshift(File.dirname(__FILE__) + '/lib')
require 'ffi_yajl/version'

Gem::Specification.new do |s|
  s.name             = 'ffi-yajl'
  s.version          = FFI_Yajl::VERSION
  s.platform         = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.summary          = "Ruby FFI wrapper around YAJL 2.x"
  s.description      = s.summary
  s.author           = "Lamont Granquist"
  s.email            = "lamont@scriptkiddie.org"
  s.homepage         = "http://github.com/lamont-granquist/ffi-yajl"

  s.extensions       = %w{ ext/libyajl2/extconf.rb ext/ffi_yajl/ext/encoder/extconf.rb ext/ffi_yajl/ext/parser/extconf.rb }

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.14"
  s.add_development_dependency "pry", "~> 0.9"
  s.add_dependency "ffi", "~> 1.9"

  s.bindir       = "bin"
  s.executables  = %w{ ffi-yajl-bench }
  s.require_path = 'lib'
  s.files        = %w{ Rakefile LICENSE README.md } +
    Dir.glob( "{lib,spec}/**/*", File::FNM_DOTMATCH ).reject { |f| File.directory?(f) }
end
