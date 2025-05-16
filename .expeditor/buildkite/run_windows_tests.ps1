param([String]$version)
# This script will run ruby test on windows platform. It requires a version
# "3.0" or "3.1" as an argument.

# Stop script execution when a non-terminating error occurs. Note that this makes it
# unneccesary to check the exit code of each program being run - non-zero exit will force it to fail and terminate.
$ErrorActionPreference = "Stop"

$gccs = gci -path c:\opscode gcc.exe -Recurse -ErrorAction SilentlyContinue
$env:path = "$($gccs[0].DirectoryName)" + ";" + $env:path

$makes = gci -Path c:\opscode make.exe -Recurse -ErrorAction SilentlyContinue
$env:path = "$($makes[0].DirectoryName)" + ";" + $env:path

Write-Output "--- Ensuring required bins are in path"
Write-Output  "PATH: " + $Env:PATH
make --version
gcc --version
ruby --version
bundler --version

Write-Output "--- Updating system gems"
gem update --system

Write-Output "--- Bundle install"
bundle install --without development_extras --jobs 3 --retry 3 --path vendor/bundle

Write-Output "--- Gem install"
gem install yajl-ruby json psych

Write-Output "--- Bundle Execute: rake compile"
bundle exec rake compile

Write-Output "--- Bundle Execute: rake spec"
bundle exec rake spec
