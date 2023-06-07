@ECHO OFF
SET PDK_BASEDIR=%~dp0..
REM Avoid the nasty \..\ littering the paths.
SET PDK_BASEDIR=%PDK_BASEDIR:\bin\..=%

REM Add PDK's bindirs to the PATH
SET PATH=%PDK_BASEDIR%\bin;%PDK_BASEDIR%\private\ruby\@@@RUBY_VERSION@@@\bin;%PATH%

REM Set the RUBY LOAD_PATH using the RUBYLIB environment variable
SET RUBYLIB=%PDK_BASEDIR%\lib;%RUBYLIB%

REM Translate all slashes to / style to avoid issue #11930
SET RUBYLIB=%RUBYLIB:\=/%

REM Set SSL variables to ensure trusted locations are used
SET SSL_CERT_FILE=%PDK_BASEDIR%\ssl\cert.pem
SET SSL_CERT_DIR=%PDK_BASEDIR%\ssl\certs
SET OPENSSL_CONF=%PDK_BASEDIR%\ssl\openssl.cnf

ruby -S -- PDK %*
