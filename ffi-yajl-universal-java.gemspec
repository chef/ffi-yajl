$:.unshift(File.dirname(__FILE__) + '/lib')
require 'ffi_yajl/version'

gemspec = eval(IO.read(File.expand_path(File.join(File.dirname(__FILE__), "ffi-yajl-shared.gemspec"))))

gemspec.platform = "universal-java"
gemspec.extensions = %w{ ext/libyajl2/extconf.rb }

gemspec

