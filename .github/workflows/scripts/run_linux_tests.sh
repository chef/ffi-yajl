#!/bin/sh
#

set -evx

echo "---Bundle install---"
ruby --version
bundle --version
gem update --system
bundle config set --local path 'vendor/bundle'
bundle config set --local without 'development_extras'
bundle install --jobs 3 --retry 3
gem install yajl-ruby json psych

echo "---Bundle Exec---"
bundle exec rake