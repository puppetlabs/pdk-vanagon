@ECHO OFF
REM Get the short path of the installation folder
SET PDK_ROOT=%~dps0..

REM Set the path to the default Ruby
SET RUBY_BIN_PATH="%PDK_ROOT%\private\ruby\@@@RUBY_VERSION@@@\bin"

REM Set our SSL variables to keep Ruby happy
SET SSL_CERT_FILE="%PDK_ROOT%\ssl\cert.pem"
SET SSL_CERT_DIR="%PDK_ROOT%\ssl\certs"

REM Execute PDK
CALL %RUBY_BIN_PATH%\ruby.exe %RUBY_BIN_PATH%\pdk %*
