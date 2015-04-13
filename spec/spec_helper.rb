$: << File.expand_path(File.join(File.dirname( __FILE__ ), "../lib"))

# load yajl-ruby into the same process (tests that both c-libs can be
# linked in the same process).  this should work, see:
# http://stackoverflow.com/questions/3232822/linking-with-multiple-versions-of-a-library
begin
  require 'yajl'
rescue LoadError
  # yajl can't be installed on jruby
end

require 'ffi_yajl'

RSpec.configure do |c|
  c.filter_run_excluding :unix_only => true unless RUBY_PLATFORM !~ /mswin|mingw|windows/
  c.filter_run_excluding :ruby_gte_19 => true unless RUBY_VERSION.to_f >= 1.9
  c.filter_run_excluding :ruby_gte_193 => true unless RUBY_VERSION.to_f >= 2.0 || RUBY_VERSION =~ /^1\.9\.3/

  c.order = 'random'

  c.expect_with :rspec do |c|
    c.syntax = :expect
  end

end
