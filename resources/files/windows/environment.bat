@ECHO OFF
REM This is the parent directory of the directory containing this script.
SET DEVKIT_BASEDIR=%~dp0..
REM Avoid the nasty \..\ littering the paths.
SET DEVKIT_BASEDIR=%DEVKIT_BASEDIR:\bin\..=%

SET RUBY_DIR=%DEVKIT_BASEDIR%\sys\ruby

SET PATH=%DEVKIT_BASEDIR%\bin;%RUBY_DIR%\bin;%DEVKIT_BASEDIR%\sdk\bin;%PATH%

REM Translate all slashes to / style to avoid issue #11930
SET RUBYLIB=%RUBYLIB:\=/%


REM Enable rubygems support
SET RUBYOPT=rubygems
REM Now return to the caller.

REM Set SSL variables to ensure trusted locations are used
REM SET SSL_CERT_FILE=%PUPPET_DIR%\ssl\cert.pem
REM SET SSL_CERT_DIR=%PUPPET_DIR%\ssl\certs

