$: << File.expand_path(File.join(File.dirname( __FILE__ ), "../lib"))

require 'ffi_yajl'

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.run_all_when_everything_filtered = true
  c.filter_run :focus

  c.order = 'random'

  c.expect_with :rspec do |c|
    c.syntax = :expect
  end

  c.filter_run_excluding :ruby_gte_19 => true if RUBY_VERSION.to_f >= 1.9
end
