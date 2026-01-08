Write-Output "--- system details"
$Properties = 'Caption', 'CSName', 'Version', 'BuildType', 'OSArchitecture'
Get-CimInstance Win32_OperatingSystem | Select-Object $Properties | Format-Table -AutoSize

Write-Output "--- Install make"
choco install make -y
refreshenv
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Installing DevKit2"
$installDir = "C:\msys_tools"
choco install msys2 --params "/NoUpdate /InstallDir:$installDir" -y
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Updating PATH"
$env:PATH = "$installDir\bin;C:\tools\DevKit2\mingw\bin;C:\tools\DevKit2\bin;" + $env:PATH
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)
refreshenv
If ($lastexitcode -ne 0) { Exit $lastexitcode }

ruby -v
bundle --version
gem -v
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- gem install bundler"
gem install bundler
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- bundle install"
bundle config set --local path 'vendor/bundle'
If ($lastexitcode -ne 0) { Exit $lastexitcode }
bundle install --without development_extras --jobs 3 --retry 3
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "+++ bundle exec rake compile"
bundle exec rake compile
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "+++ bundle exec rake spec"
bundle exec rake spec
If ($lastexitcode -ne 0) { Exit $lastexitcode }