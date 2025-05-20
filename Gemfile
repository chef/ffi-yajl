source "https://rubygems.org"

gemspec name: "ffi-yajl"

group :development do
  # for testing loading concurrently with yajl-ruby, not on jruby
  # gem 'yajl-ruby', platforms: [ :ruby, :mswin, :mingw ]
  gem "ffi"
  gem "rake" # , ">= 10.1"
  gem "rspec" # , "~> 3.0"
  gem "pry", "~> 0.9"
  gem "rake-compiler" # , "~> 1.0"
  gem "rack" # , "~> 2.0"
end

instance_eval(ENV["GEMFILE_MOD"]) if ENV["GEMFILE_MOD"]

# If you want to load debugging tools into the bundle exec sandbox,
# add these additional dependencies into Gemfile.local
eval_gemfile(__FILE__ + ".local") if File.exist?(__FILE__ + ".local")
