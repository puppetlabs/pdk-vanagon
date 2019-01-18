$fso = New-Object -ComObject Scripting.FileSystemObject

$env:DEVKIT_BASEDIR = (Get-ItemProperty -Path "HKLM:\Software\Puppet Labs\DevelopmentKit").RememberedInstallDir64
# Windows API GetShortPathName requires inline C#, so use COM instead
$env:DEVKIT_BASEDIR = $fso.GetFolder($env:DEVKIT_BASEDIR).ShortPath
$env:RUBY_DIR       = "$($env:DEVKIT_BASEDIR)\private\ruby\2.4.5"
$env:SSL_CERT_FILE  = "$($env:DEVKIT_BASEDIR)\ssl\cert.pem"
$env:SSL_CERT_DIR   = "$($env:DEVKIT_BASEDIR)\ssl\certs"

function pdk {
  if ($env:ConEmuANSI -eq 'ON') {
    &$env:RUBY_DIR\bin\ruby -S -- $env:RUBY_DIR\bin\pdk $args
  } else {
    &$env:DEVKIT_BASEDIR\private\tools\bin\ansicon.exe $env:RUBY_DIR\bin\ruby -S -- $env:RUBY_DIR\bin\pdk $args
  }
}

Export-ModuleMember -Function pdk -Variable *
