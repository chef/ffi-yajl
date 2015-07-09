# Copyright (c) 2015 Lamont Granquist
# Copyright (c) 2015 Chef Software, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

$LOAD_PATH << File.expand_path(File.join(File.dirname( __FILE__ ), "../lib"))

# load yajl-ruby into the same process (tests that both c-libs can be
# linked in the same process).  this should work, see:
# http://stackoverflow.com/questions/3232822/linking-with-multiple-versions-of-a-library
begin
  require 'yajl'
rescue LoadError
  puts 'WARN: yajl cannot be loaded, expected if this is jruby'
end

require 'ffi_yajl'

RSpec.configure do |conf|
  conf.filter_run_excluding unix_only: true unless RUBY_PLATFORM !~ /mswin|mingw|windows/
  conf.filter_run_excluding ruby_gte_193: true unless RUBY_VERSION.to_f >= 2.0 || RUBY_VERSION =~ /^1\.9\.3/

  conf.order = 'random'

  conf.expect_with :rspec do |rspec|
    rspec.syntax = :expect
  end
end
