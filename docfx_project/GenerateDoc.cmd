powershell -ExecutionPolicy ByPass -command "./Provision.ps1 -Version 100.8.0"
..\.tools\nuget install memberpage -OutputDirectory plugins -Version 2.46.0
REM TODO: Process all versions and merge APIs
REM For now just use net461 YAML
DEL API\*.* /Q /S
XCOPY ..\.packages\100.6.0\.api\net461\*.* /S API\
REM Build documentation
..\.tools\docfx\docfx.exe build
PAUSE
