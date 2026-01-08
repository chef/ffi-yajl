#!/bin/sh
#

set -evx

echo "---Bundle install---"
ruby --version
bundle --version
gem update --system
bundle config set --local path 'vendor/bundle'
bundle install --without development_extras --jobs 3 --retry 3
gem install yajl-ruby json psych

echo "---Bundle Exec---"
bundle exec rake