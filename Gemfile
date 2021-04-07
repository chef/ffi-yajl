source "https://rubygems.org"

gemspec name: "ffi-yajl"

group :development do
  # for testing loading concurrently with yajl-ruby, not on jruby
  # gem 'yajl-ruby', platforms: [ :ruby, :mswin, :mingw ]
  gem "ffi"
  gem "rake", ">= 10.1"
  gem "rspec", "~> 3.0"
  gem "pry", "~> 0.9"
  gem "rake-compiler", "~> 1.0"
  gem "rack", "~> 2.0"
end

group :development_extras do
  gem "chefstyle"
end
