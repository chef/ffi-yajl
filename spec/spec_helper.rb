$: << File.expand_path(File.join(File.dirname( __FILE__ ), "../lib"))

require 'ffi_yajl'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
