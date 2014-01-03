gemspec = eval(IO.read(File.expand_path(File.join(File.dirname(__FILE__), "ffi-yajl.gemspec.shared"))))

gemspec.platform = Gem::Platform::RUBY
gemspec.extensions = %w{ ext/libyajl2/extconf.rb ext/ffi_yajl/ext/encoder/extconf.rb ext/ffi_yajl/ext/parser/extconf.rb }

gemspec

