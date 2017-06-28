# This is the parent directory of the directory containing this script.
$DEVKIT_BASEDIR = (Get-Item $PSScriptRoot).Parent.FullName

# Currently not used but might be added to $PATH at some point.
# $RUBY_DIR = "$DEVKIT_BASEDIR\private\ruby\2.1.9"

$env:Path = "$DEVKIT_BASEDIR\bin;$env:Path"

# Set SSL variables to ensure trusted locations are used
$env:SSL_CERT_FILE = "$DEVKIT_BASEDIR\ssl\cert.pem"
$env:SSL_CERT_DIR = "$DEVKIT_BASEDIR\ssl\certs"

# Enable rubygems support
$env:RUBYOPT = 'rubygems'

Set-Location "$env:USERPROFILE\Documents"

Write-Host "Puppet Development Kit activated.`n"
Write-Host "For more information, run pdk --help`n"
