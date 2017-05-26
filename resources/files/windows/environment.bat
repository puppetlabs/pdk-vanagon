@ECHO OFF
REM This is the parent directory of the directory containing this script.
SET DEVKIT_BASEDIR=%~dps0..
REM Avoid the nasty \..\ littering the paths.
SET DEVKIT_BASEDIR=%DEVKIT_BASEDIR:\bin\..=%

SET RUBY_DIR=%DEVKIT_BASEDIR%\private\ruby\2.1.9

SET PATH=%DEVKIT_BASEDIR%\bin;%PATH%

REM Translate all slashes to / style to avoid issue #11930
SET RUBYLIB=%RUBYLIB:\=/%

REM Set SSL variables to ensure trusted locations are used
SET SSL_CERT_FILE=%DEVKIT_BASEDIR%\ssl\cert.pem
SET SSL_CERT_DIR=%DEVKIT_BASEDIR%\ssl\certs

REM Enable rubygems support
SET RUBYOPT=rubygems
REM Now return to the caller.
