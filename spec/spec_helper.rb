$: << File.expand_path(File.join(File.dirname( __FILE__ ), "../lib"))

require 'ffi_yajl'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |c|
  c.filter_run_excluding :ruby_gte_19 => true unless RUBY_VERSION.to_f >= 1.9

  c.order = 'random'

  c.expect_with :rspec do |c|
    c.syntax = :expect
  end

end
