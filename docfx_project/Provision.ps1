[cmdletbinding()]
param(
   [string]$Version="100.6.0"
)
Add-Type -AssemblyName System.IO.Compression.FileSystem

function DownloadDocFX()
{
   if (!(Test-Path "..\.tools\docfx\"))
   {
    New-Item -ItemType Directory -Force -Path "..\.tools\docfx"
      Write-Output "Downloading $packageId v$version..."
      Invoke-WebRequest -Uri "https://github.com/dotnet/docfx/releases/download/v2.45.1/docfx.zip" -OutFile "..\.tools\docfx.zip"
      [System.IO.Compression.ZipFile]::ExtractToDirectory("..\.tools\docfx.zip", "..\.tools\docfx")
   }
}
function DownloadNuget([string]$packageId, [string]$version)
{
   if (!(Test-Path "..\.tmp"))
   {
      New-Item -ItemType Directory -Force -Path "..\.tmp"
   }
   if (!(Test-Path "..\.tmp\$packageId-$version.nupkg"))
   {
      Write-Output "Downloading $packageId v$version..."
      Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/$packageId/$version" -OutFile "..\.tmp\$packageId-$version.nupkg"
   }
   else
   {
     Write-Output "$packageId v$version already downloaded"
   }
}
function UnZipNuget([string]$packageId, [string]$version)
{
  if (!(Test-Path "..\.tmp\$packageId\$version"))
  {
    New-Item -ItemType Directory -Force -Path "..\.tmp\$packageId\$version"
    [System.IO.Compression.ZipFile]::ExtractToDirectory("..\.tmp\$packageId\$version.nupkg", "..\.tmp\$packageId\$version")
  }
}
function GetNugetLibs([string]$packageId, [string]$version)
{
  DownloadNuget -packageId $packageId -version $version
  UnZipNuget -packageId $packageId -version $version
  foreach($dir in Get-ChildItem -Path "..\.tmp\$packageId\$version\lib" -Directory)
  {
    #Write-Output $dir | Select-Object FullName
    $dirname = [string]($dir | Select-Object -expand Name);
    $dirfullname = ($dir | Select-Object -expand FullName)
	if (!(Test-Path "src\$version\$dirname"))
    {
      foreach($file in Get-ChildItem -Path "$dirfullname")
      {
        $filename = ($file | Select-Object -expand FullName)
        if ($filename.endswith(".dll") -Or $filename.endswith(".xml"))
        {
          Write-Output $filename
          New-Item -ItemType Directory -Force -Path "src\$version\$dirname"
          Copy-Item "$filename" "src\$version\$dirname\"
        }
      }
	}
  }
}

# $Version="100.6.0"
DownloadDocFX
GetNugetLibs -packageId "Esri.ArcGISRuntime" -version $Version
GetNugetLibs -packageId "Esri.ArcGISRuntime.WPF" -version $Version
GetNugetLibs -packageId "Esri.ArcGISRuntime.Xamarin.Android" -version $Version
GetNugetLibs -packageId "Esri.ArcGISRuntime.UWP" -version $Version
GetNugetLibs -packageId "Esri.ArcGISRuntime.Xamarin.iOS" -version $Version
GetNugetLibs -packageId "Esri.ArcGISRuntime.Hydrography" -version $Version
GetNugetLibs -packageId "Esri.ArcGISRuntime.LocalServices" -version $Version
GetNugetLibs -packageId "Esri.ArcGISRuntime.Xamarin.Forms" -version $Version
