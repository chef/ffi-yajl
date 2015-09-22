source "https://rubygems.org"

gemspec name: "ffi-yajl"

platforms :rbx do
  gem "rubysl", "~> 2.0"
end

group :development do
  # for testing loading concurrently with yajl-ruby, not on jruby
  gem "yajl-ruby", platforms: [:ruby, :mswin, :mingw]
  gem "github_changelog_generator"
end

group :development_extras do
  gem "finstyle", "= 1.5.0"
  gem "reek", "= 1.3.7"
  gem "test-kitchen", "~> 1.2"
  gem "kitchen-digitalocean"
  gem "kitchen-ec2"
  gem "kitchen-vagrant"
end
