module Platform
  def self.windows?
    !!(RUBY_PLATFORM =~ /mswin|mingw|cygwin|windows/)
  end
end