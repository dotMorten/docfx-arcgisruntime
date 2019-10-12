powershell -ExecutionPolicy ByPass -command "./Provision.ps1 -Version 100.6.0"
REM Generate metadata:
..\.tools\docfx\docfx.exe metadata 
REM Generate metadata:
..\.tools\docfx\docfx.exe merge
REM Build documentation
REM ..\.tools\docfx\docfx.exe build
PAUSE
