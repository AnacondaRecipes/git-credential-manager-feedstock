cd src\windows\Installer.Windows\
if errorlevel 1 exit /b %errorlevel%

powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File ".\layout.ps1" -Configuration WindowsRelease -Output payload -SymbolOutput symbols
if errorlevel 1 exit /b %errorlevel%

cd payload
if errorlevel 1 exit /b %errorlevel%

rem Already exists in the package
if exist NOTICE del NOTICE
if errorlevel 1 exit /b %errorlevel%

move * %LIBRARY_BIN%

dotnet build-server shutdown >NUL 2>&1 || echo "Warning: dotnet build-server shutdown failed (ignored)"
