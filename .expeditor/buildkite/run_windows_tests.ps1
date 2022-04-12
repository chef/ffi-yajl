# Stop script execution when a non-terminating error occurs
$ErrorActionPreference = "Stop"

# This will run ruby test on windows platform

echo "--- Install make "
choco install make --source=cygwin
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Bundle install"
ruby --version
bundler --version
gem update --system
If ($lastexitcode -ne 0) { Exit $lastexitcode }
bundle install --without development_extras --jobs 3 --retry 3 --path vendor/bundle
If ($lastexitcode -ne 0) { Exit $lastexitcode }
gem install yajl-ruby json psych
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Bundle Execute"
bundle exec rake compile
If ($lastexitcode -ne 0) { Exit $lastexitcode }
bundle exec rake spec
If ($lastexitcode -ne 0) { Exit $lastexitcode }