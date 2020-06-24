[cmdletbinding()]
param(
   [string]$Version="100.8.0"
)
Add-Type -AssemblyName System.IO.Compression.FileSystem

function DownloadNuGetCLI()
{
   if (!(Test-Path "..\.tools\nuget.exe"))
   {
      New-Item -ItemType Directory -Force -Path "..\.tools\docfx"
      Write-Output "Downloading nuget..."
      Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "..\.tools\nuget.exe"
   }
}
function DownloadDocFX()
{
   if (!(Test-Path "..\.tools\docfx\docfx.exe"))
   {
    New-Item -ItemType Directory -Force -Path "..\.tools\docfx"
      Write-Output "Downloading DocFX..."
      Invoke-WebRequest -Uri "https://github.com/dotnet/docfx/releases/download/v2.55/docfx.zip" -OutFile "..\.tools\docfx.zip"
      [System.IO.Compression.ZipFile]::ExtractToDirectory("..\.tools\docfx.zip", "..\.tools\docfx")
   }
}
function DownloadPackage([string] $packageId, [string]$version)
{
  if (!(Test-Path "..\.packages\$version\$packageId.$version"))
  {
    ..\.tools\nuget install $packageId -version $version -OutputDirectory ..\.packages\$version\ -DirectDownload -Framework netstandard1.0
  }
}
function DownloadPackages([string]$version)
{
  DownloadPackage -packageId Esri.ArcGISRuntime -version $version 
  DownloadPackage -packageId Esri.ArcGISRuntime.WPF -version $version
  DownloadPackage -packageId Esri.ArcGISRuntime.Xamarin.Android -version $version
  DownloadPackage -packageId Esri.ArcGISRuntime.Xamarin.iOS -version $version
  DownloadPackage -packageId Esri.ArcGISRuntime.UWP -version $version
  DownloadPackage -packageId Esri.ArcGISRuntime.Hydrography -version $version
  DownloadPackage -packageId Esri.ArcGISRuntime.LocalServices -version $version
  DownloadPackage -packageId Esri.ArcGISRuntime.Xamarin.Forms -version $version
}
function GenerateMetadataManifest([string]$version)
{
  #$tfmdict = New-Object "System.Collections.Generic.Dictionary``2[System.String,List``System.String]"
  $tfmtable = @{}
  foreach($dir in Get-ChildItem -Path "..\.packages\$version\*\lib\" -Directory)
  {
    #Write-Output $dir | Select-Object FullName
    #$tfm = [string]($dir | Select-Object -expand Name);
    $dirfullname = ($dir | Select-Object -expand FullName)
    if ($dirfullname.contains("\Esri.ArcGISRuntime."))
    {
  
    foreach($tfmdir in Get-ChildItem -Path "$dirfullname" -Directory)
    {
      $tfm = [string]($tfmdir | Select-Object -expand Name);
      $tfmfullname = [string]($tfmdir | Select-Object -expand FullName);
      if (!$tfmtable.contains($tfm))
      {
        $tfmtable.Add($tfm, @())
      }
      foreach($file in Get-ChildItem -Path "$tfmfullname" -File)
      { 
        $filename = [string]($file | Select-Object -expand FullName)
        if ($filename.endswith(".dll"))
        {
          $tfmtable["$tfm"] += $tfmfullname
          Break
        }
      }
    }
  }
  }
  New-Item "..\.packages\$version\docfx.json" -ItemType File -Value "{`n  `"metadata`":[`n" -force
  $rootPath = Resolve-Path -Path "..\.packages\$version\";
  foreach($tfm in $tfmtable.GetEnumerator())
  {
    $tfmkey = $tfm.Key
    $folders = $tfm.Value
    Add-Content "..\.packages\$version\docfx.json" "  {`n    `"src`":[{";
    Add-Content "..\.packages\$version\docfx.json" "      `"files`":[";
    foreach($foldername in $folders)
    {
      $fname = $foldername.replace("$rootPath","").replace("\","/")
      Add-Content "..\.packages\$version\docfx.json" "        `"$fname`/*.dll`",";
    }
    Add-Content "..\.packages\$version\docfx.json" "      ],";
    Add-Content "..\.packages\$version\docfx.json" "    }],";
    Add-Content "..\.packages\$version\docfx.json" "    `"dest`":`".api/$tfmkey`",";
    Add-Content "..\.packages\$version\docfx.json" "    `"properties`":{`"TargetFramework`":`"$tfmkey`"},";
    Add-Content "..\.packages\$version\docfx.json" "  },";
  }
  Add-Content "..\.packages\$version\docfx.json" "  ]`n}"
}
function GenerateAPIMetadata([string]$version)
{
  DownloadPackages -version $version;
  if (!(Test-Path "..\.packages\$version\.api"))
  {
    GenerateMetadataManifest($version);
    ..\.tools\docfx\docfx.exe "..\.packages\$version\docfx.json"
  }
}
DownloadNuGetCLI
DownloadDocFX
GenerateAPIMetadata -version "100.8.0";
GenerateAPIMetadata -version "100.7.0";
GenerateAPIMetadata -version "100.6.0";
GenerateAPIMetadata -version "100.5.0";
GenerateAPIMetadata -version "100.4.0";
GenerateAPIMetadata -version "100.3.0";
GenerateAPIMetadata -version "100.2.1";
GenerateAPIMetadata -version "100.2.0";
GenerateAPIMetadata -version "100.1.0";
GenerateAPIMetadata -version "100.0.0";
