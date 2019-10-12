powershell -ExecutionPolicy ByPass -command "./build.ps1 -Version 100.6.0"
PAUSE
SET PATH=E:\DocFX\bin;%PATH%
REM Generate metadata:
REM docfx.exe metadata 
REM Generate metadata:
REM docfx.exe merge
REM XCOPY _api\*.* api\ /S /Y
REM ..\bin\docfx.exe build
