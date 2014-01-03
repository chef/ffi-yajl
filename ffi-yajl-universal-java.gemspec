gemspec = eval(IO.read(File.expand_path(File.join(File.dirname(__FILE__), "ffi-yajl.gemspec.shared"))))

gemspec.platform = "universal-java"
gemspec.extensions = %w{ ext/libyajl2/extconf.rb }

gemspec

