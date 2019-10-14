echo "--- system details"
$Properties = 'Caption', 'CSName', 'Version', 'BuildType', 'OSArchitecture'
Get-CimInstance Win32_OperatingSystem | Select-Object $Properties | Format-Table -AutoSize

echo "--- Install make and ruby2.devkit"
choco install make ruby ruby2.devkit -y
refreshenv

echo - c:\tools\ruby26 > c:\tools\Devkit2\config.yml
ruby c:\tools\Devkit2\dk.rb install

choco install msys2 -y
refreshenv

Write-Output 'Updating PATH'
$env:PATH = "C:\tools\ruby26\bin;C:\tools\DevKit2\mingw\bin;C:\tools\DevKit2\bin;" + $env:PATH
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

ruby -v
bundle --version
gem -v

C:\tools\ruby26\ridk_use\ridk.cmd install 3
C:\tools\ruby26\ridk_use\ridk.cmd  enable

echo "--- gem install bundler"
gem install bundler

echo "--- bundle install"
bundle install --without development_extras --jobs 3 --retry 3 --path vendor/bundle

echo "+++ bundle exec rake compile"
bundle exec rake compile

echo "+++ bundle exec rake spec"
bundle exec rake spec

exit $LASTEXITCODE