function pdk {
  $fso = New-Object -ComObject Scripting.FileSystemObject
  $devkit_basedir = $fso.GetFolder((Get-ItemProperty -Path "HKLM:\Software\Puppet Labs\DevelopmentKit").RememberedInstallDir64).ShortPath
  $ruby_dir = "$($devkit_basedir)\private\ruby\2.4.5"
  $envvars = @{
    'DEVKIT_BASEDIR' = $devkit_basedir;
    'RUBY_DIR' = $ruby_dir;
    'SSL_CERT_FILE' = "$($devkit_basedir)\ssl\cert.pem";
    'SSL_CERT_DIR' = "$($devkit_basedir)\ssl\certs";
    'RUBYLIB' = $null;
    'RUBYLIB_PREFIX' = $null;
    'RUBYOPT' = $null;
    'RUBYPATH' = $null;
    'RUBYSHELL' = $null;
    'DLN_LIBRARY_PATH' = $null;
    'LD_PRELOAD' = $null;
    'LD_LIBRARY_PATH' = $null;
    'GEM_HOME' = $null;
  }

  $process = New-Object System.Diagnostics.Process

  if ($env:ConEmuANSI -eq 'ON') {
    $process.StartInfo.FileName = "$($ruby_dir)\bin\ruby"
    $process.StartInfo.Arguments = "-S -- $($ruby_dir)\bin\pdk $($args)"
  } else {
    $process.StartInfo.FileName = "$($devkit_basedir)\private\tools\bin\ansicon.exe"
    $process.StartInfo.Arguments = "$($ruby_dir)\bin\ruby -S -- $($ruby_dir)\bin\pdk $($args)"
  }

  ForEach($envvar in $envvars.GetEnumerator()) {
    $process.StartInfo.EnvironmentVariables[$envvar.Key] = $envvar.Value
  }

  $process.StartInfo.WorkingDirectory = Convert-Path .
  $process.StartInfo.UseShellExecute = $false
  if ($process.Start()) { $process.WaitForExit() }
}

Export-ModuleMember -Function pdk
