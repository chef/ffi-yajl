$: << File.expand_path(File.join(File.dirname( __FILE__ ), "../lib"))

require 'ffi_yajl'

RSpec.configure do |c|
  c.filter_run_excluding :ruby_gte_19 => true unless RUBY_VERSION.to_f >= 1.9
  c.filter_run_excluding :ruby_gte_193 => true unless RUBY_VERSION.to_f >= 2.0 || RUBY_VERSION =~ /^1\.9\.3/

  c.order = 'random'

  c.expect_with :rspec do |c|
    c.syntax = :expect
  end

end
