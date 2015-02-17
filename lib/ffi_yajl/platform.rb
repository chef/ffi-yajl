module FFI_Yajl
  module Platform
    def windows?
      !!(RUBY_PLATFORM =~ /mswin|mingw|cygwin|windows/)
    end
  end
end
