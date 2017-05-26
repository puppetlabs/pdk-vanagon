@echo off
SETLOCAL

call "%~dp0environment.bat" %0 %*

%RUBY_DIR%\bin\ruby -S -- %RUBY_DIR%\bin\pdk %*
