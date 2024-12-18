param([String]$version)
# This script will run ruby test on windows platform. It requires a version
# "3.0" or "3.1" as an argument.

# Stop script execution when a non-terminating error occurs. Note that this makes it
# unneccesary to check the exit code of each program being run - non-zero exit will force it to fail and terminate.
$ErrorActionPreference = "Stop"

# The specific paths of tools within the ruby30/31 devkit vary a bit across 3.0 and 3.1
if ($version -eq "3.0")
{
    $base_dir = "C:\ruby30\"
    $Env:PATH += ";" + $base_dir + "ruby\bin;" + $base_dir + "msys64\usr\bin;" + $base_dir + "msys64\mingw64\bin"
}
elseif($version -eq "3.1")
{
    $base_dir = "C:\ruby31\"
    # Note path change - gcc is living in ucrt64\bin here, and mingw64 in earlier versions.
    $Env:PATH += ";" + $base_dir + "ruby\bin;" + $base_dir + "msys64\usr\bin;" + $base_dir + "msys64\ucrt64\bin"
}

Write-Output "--- Ensuring required bins are in path"
Write-Output  "PATH: " + $Env:PATH
make --version
gcc --version
ruby --version
bundler --version

Write-Output "--- Updating system gems"
gem update

Write-Output "--- Bundle install"
bundle install --without development_extras --jobs 3 --retry 3 --path vendor/bundle

Write-Output "--- Gem install"
gem install yajl-ruby json psych

Write-Output "--- Bundle Execute: rake compile"
bundle exec rake compile

Write-Output "--- Bundle Execute: rake spec"
bundle exec rake spec
