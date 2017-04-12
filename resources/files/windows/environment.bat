@ECHO OFF
REM This is the parent directory of the directory containing this script.
SET PL_BASEDIR=%~dp0..
REM Avoid the nasty \..\ littering the paths.
SET PL_BASEDIR=%PL_BASEDIR:\bin\..=%

REM Set a fact so we can easily source the environment.bat file in the future.
REM SET FACTER_env_windows_installdir=%PL_BASEDIR%

REM SET PUPPET_DIR=%PL_BASEDIR%\puppet
REM REM Facter will load FACTER_ env vars as facts, so don't use FACTER_DIR
REM SET FACTERDIR=%PL_BASEDIR%\facter
REM SET HIERA_DIR=%PL_BASEDIR%\hiera
REM SET MCOLLECTIVE_DIR=%PL_BASEDIR%\mcollective
SET RUBY_DIR=%PL_BASEDIR%\sys\ruby

SET PATH=%PL_BASEDIR%\bin;%RUBY_DIR%\bin;%PL_BASEDIR%\sys\tools\bin;%PATH%

REM Set the RUBY LOAD_PATH using the RUBYLIB environment variable
REM SET RUBYLIB=%PUPPET_DIR%\lib;%FACTERDIR%\lib;%HIERA_DIR%\lib;%MCOLLECTIVE_DIR%\lib;%RUBYLIB%

REM Translate all slashes to / style to avoid issue #11930
SET RUBYLIB=%RUBYLIB:\=/%


REM Enable rubygems support
SET RUBYOPT=rubygems
REM Now return to the caller.

REM Set SSL variables to ensure trusted locations are used
REM SET SSL_CERT_FILE=%PUPPET_DIR%\ssl\cert.pem
REM SET SSL_CERT_DIR=%PUPPET_DIR%\ssl\certs

