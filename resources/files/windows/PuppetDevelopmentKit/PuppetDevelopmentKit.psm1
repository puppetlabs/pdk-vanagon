$env:DEVKIT_BASEDIR = (Get-ItemProperty -Path "HKLM:\Software\Puppet Labs\DevelopmentKit").RememberedInstallDir64
$env:RUBY_DIR       = "$($env:DEVKIT_BASEDIR)\private\ruby\2.1.9"
$env:PATH           = "$($env:DEVKIT_BASEDIR)\bin;%PATH%"
$env:SSL_CERT_FILE  = "$($env:DEVKIT_BASEDIR)\ssl\cert.pem"
$env:SSL_CERT_DIR   = "$($env:DEVKIT_BASEDIR)\ssl\certs"

function pdk{
  &$env:DEVKIT_BASEDIR\private\tools\bin\ansicon.exe $env:RUBY_DIR\bin\ruby -S -- $env:RUBY_DIR\bin\pdk $args
}

Export-ModuleMember -Function pdk -Variable *
