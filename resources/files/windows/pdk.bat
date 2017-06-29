@echo off
SETLOCAL

call "%~dp0environment.bat" %0 %*

%DEVKIT_BASEDIR%\private\tools\bin\ansicon.exe %RUBY_DIR%\bin\ruby -S -- %RUBY_DIR%\bin\pdk %*
