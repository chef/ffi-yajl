$:.unshift(File.dirname(__FILE__) + '/lib')
require 'ffi_yajl/version'

gemspec = eval(IO.read(File.expand_path(File.join(File.dirname(__FILE__), "ffi-yajl-shared.gemspec"))))

gemspec.platform = Gem::Platform::RUBY
gemspec.extensions = %w{ ext/libyajl2/extconf.rb ext/ffi_yajl/ext/encoder/extconf.rb ext/ffi_yajl/ext/parser/extconf.rb }

gemspec

