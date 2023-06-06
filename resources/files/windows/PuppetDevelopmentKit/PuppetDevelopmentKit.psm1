$fso = New-Object -ComObject Scripting.FileSystemObject

$script:DEVKIT_BASEDIR = (Get-ItemProperty -Path "HKLM:\Software\Puppet Labs\DevelopmentKit").RememberedInstallDir64
# Windows API GetShortPathName requires inline C#, so use COM instead
$script:DEVKIT_BASEDIR_SHORT = $fso.GetFolder($script:DEVKIT_BASEDIR).ShortPath
$script:RUBY_DIR = "$($script:DEVKIT_BASEDIR)\private\ruby\@@@RUBY_VERSION@@@"

function pdk {
  if ($Host.Name -eq 'Windows PowerShell ISE Host') {
    Write-Error ("The Puppet Development Kit cannot be run in the Windows PowerShell ISE.`n" + `
                "Open a new Windows PowerShell Console, or 'Start-Process PowerShell', and use PDK within this new console.`n" + `
                "For more information see https://puppet.com/docs/pdk/latest/pdk_known_issues.html and https://devblogs.microsoft.com/powershell/console-application-non-support-in-the-ise.")
    return
  }

  # Reset The SSL Environment Variables
  $env:SSL_CERT_FILE  = "$($script:DEVKIT_BASEDIR)\ssl\cert.pem"
  $env:SSL_CERT_DIR   = "$($script:DEVKIT_BASEDIR)\ssl\certs"

  # Don't use Ansicon under the following circumstances
  $skip_ansicon = (
    # ConEmuANSI is set to ON for Conemu
    ($env:ConEmuANSI -eq 'ON') -or
    # WT_SESSION is set when using Windows Terminal
    ($null -ne $ENV:WT_SESSION) -or
    # TERM_PROGRAM is set when using VS Code intergrated terminal
    ($null -ne $ENV:TERM_PROGRAM) -or
    # Host.Name is set to ServerRemoteHost for a remote PowerShell session.
    ($Host.Name -eq 'ServerRemoteHost')
  )

  if ($skip_ansicon) {
    &$script:RUBY_DIR\bin\ruby -S -- $script:RUBY_DIR\bin\pdk $args
  } else {
    &$script:DEVKIT_BASEDIR_SHORT\private\tools\bin\ansicon.exe $script:RUBY_DIR\bin\ruby -S -- $script:RUBY_DIR\bin\pdk $args
  }
}

Export-ModuleMember -Function pdk -Variable *
