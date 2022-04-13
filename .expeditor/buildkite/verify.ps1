echo "--- system details"
$Properties = 'Caption', 'CSName', 'Version', 'BuildType', 'OSArchitecture'
Get-CimInstance Win32_OperatingSystem | Select-Object $Properties | Format-Table -AutoSize

echo "--- Install make"
choco install make -y
refreshenv
If ($lastexitcode -ne 0) { Exit $lastexitcode }

choco install msys2 -y
refreshenv
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output 'Updating PATH'
$env:PATH = "C:\tools\ruby26\bin;C:\tools\DevKit2\mingw\bin;C:\tools\DevKit2\bin;" + $env:PATH
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)
If ($lastexitcode -ne 0) { Exit $lastexitcode }

ruby -v
bundle --version
gem -v
If ($lastexitcode -ne 0) { Exit $lastexitcode }

echo "--- gem install bundler"
gem install bundler
If ($lastexitcode -ne 0) { Exit $lastexitcode }

echo "--- bundle install"
bundle install --without development_extras --jobs 3 --retry 3 --path vendor/bundle
If ($lastexitcode -ne 0) { Exit $lastexitcode }

echo "+++ bundle exec rake compile"
bundle exec rake compile
If ($lastexitcode -ne 0) { Exit $lastexitcode }

echo "+++ bundle exec rake spec"
bundle exec rake spec
If ($lastexitcode -ne 0) { Exit $lastexitcode }