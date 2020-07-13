source "https://rubygems.org"

gemspec name: "ffi-yajl"

platforms :rbx do
  gem "rubysl", "~> 2.0"
end

group :development do
  # for testing loading concurrently with yajl-ruby, not on jruby
  # gem 'yajl-ruby', platforms: [ :ruby, :mswin, :mingw ]
  gem "rspec"
  gem "rake-compiler"
end

group :development_extras do
  gem "chefstyle"
end
