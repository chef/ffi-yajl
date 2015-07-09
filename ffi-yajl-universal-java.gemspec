gemspec = eval(IO.read(File.expand_path(File.join(File.dirname(__FILE__), "ffi-yajl.gemspec.shared"))))

gemspec.platform = "universal-java"

# XXX: after the libyajl2-gem, we don't need to fork the
# extensions so can we simplify the gemspecs now?
# gemspec.extensions = %w{ ext/libyajl2/extconf.rb }

gemspec.add_runtime_dependency "ffi", "~> 1.5"

gemspec
