<#
.SYNOPSIS
    Initializes this repository
.NOTES
    THIS FILE IS MAINTAINED BY A TOOL.
    MANUAL CHANGES WILL BE LOST UNLESS ADDED TO THE "user defined _init" SECTION.
#>
#Requires -Version 6.0
[CmdletBinding()]
param (
    # If set will disable the compatible/incompatible cmdlet output at the end of the script
    [Parameter(
        Mandatory = $false
    )]
    [switch]
    $SuppressOutput
)
# Stop on errors
$ErrorActionPreference = 'Stop'

Write-Host 'Initialising repository, please wait...'

# We use this well-known global variable across a variety of projects for storing cmdlet names/summaries so we can output them if desired.
$Global:BrownserveCmdlets = @()

# If we're on Teamcity set the well-known $env:CI variable, this is set on most other CI/CD providers but not Teamcity :(
if ($env:TEAMCITY_VERSION)
{
    Write-Verbose 'Running on Teamcity, setting $env:CI'
    $env:CI = $true
}
    
# Suppress output on CI/CD - it's noisy
if ($env:CI)
{
    $SuppressOutput = $true
}

# Set up our permanent paths
# This directory is the root of the repo, it's handy to reference sometimes
$Global:BrownserveRepoRootDirectory = (Resolve-Path (Get-Item $PSScriptRoot -Force).PSParentPath) | Convert-Path # -Force flag is needed to find dot folders on *.nix
# Contains build configuration along with this _init.ps1 script
$Global:BrownserveRepoBuildDirectory = Join-Path $global:BrownserveRepoRootDirectory -ChildPath '.build' | Convert-Path
# Stores any tasks that we pass to Invoke-Build
$Global:BrownserveRepoBuildTasksDirectory = Join-Path $global:BrownserveRepoRootDirectory -ChildPath '.build' -AdditionalChildPath 'tasks' | Convert-Path
# Stores the PowerShell module
$Global:BrownserveModuleDirectory = Join-Path $global:BrownserveRepoRootDirectory -ChildPath 'Module' | Convert-Path
# Stores any tests that we pass to Pester
$Global:BrownserveRepoTestsDirectory = Join-Path $global:BrownserveRepoRootDirectory -ChildPath '.build' -AdditionalChildPath 'tests' | Convert-Path


# Get the name of the repo
$Global:BrownserveRepoName = Split-Path $Global:BrownserveRepoRootDirectory -Leaf

# Set-up our ephemeral paths, that is those that will be destroyed and then recreated each time this script is called
# EphemeralDirectories are destroyed and recreated by this script
# EphemeralPaths are destroyed but are not recreated, we assume whatever created them in the first place will do so again (e.g. paket.lock)
$EphemeralDirectories = @(
    ($BrownserveRepoTempDirectory = Join-Path -Path $global:BrownserveRepoRootDirectory -ChildPath '.tmp'),
    ($BrownserveRepoLogDirectory = Join-Path -Path $global:BrownserveRepoRootDirectory -ChildPath '.tmp' -AdditionalChildPath 'logs'),
    ($BrownserveRepoBuildOutputDirectory = Join-Path -Path $global:BrownserveRepoRootDirectory -ChildPath '.tmp' -AdditionalChildPath 'output'),
    ($BrownserveRepoBinaryDirectory = Join-Path -Path $global:BrownserveRepoRootDirectory -ChildPath '.tmp' -AdditionalChildPath 'bin'),
    ($BrownserveRepoNugetPackagesDirectory = Join-Path -Path $global:BrownserveRepoRootDirectory -ChildPath 'packages'),
    ($BrownserveRepoPaketFilesDirectory = Join-Path -Path $global:BrownserveRepoRootDirectory -ChildPath 'paket-files')
)
$EphemeralFiles = @(
    Join-Path -Path $global:BrownserveRepoRootDirectory -ChildPath 'paket.lock'
)
try
{
    if ($EphemeralDirectories.Count -gt 0)
    {
        Write-Verbose 'Destroying any preexisting ephemeral directories'
        $EphemeralDirectories | ForEach-Object {
            if ((Test-Path $_))
            {
                Remove-Item $_ -Recurse -Force | Out-Null
            }
            New-Item $_ -ItemType Directory -Force | Out-Null
        }
    }
    if ($EphemeralFiles.Count -gt 0)
    {
        Write-Verbose 'Destroying any preexisting ephemeral files'
        $EphemeralFiles | ForEach-Object {
            if ((Test-Path $_))
            {
                Remove-Item $_ -Recurse -Force | Out-Null
            }
        }
    }
}
catch
{
    throw "Failed to process ephemeral paths.`n$($_.Exception.Message)"
}

# Now that the ephemeral paths definitely exist we are free to set their global variables

# Used to store temporary files created for builds/tests
$global:BrownserveRepoTempDirectory = $BrownserveRepoTempDirectory | Convert-Path
# Used to store build logs, output from Invoke-NativeCommand and the like
$global:BrownserveRepoLogDirectory = $BrownserveRepoLogDirectory | Convert-Path
# Used to store any output from builds (e.g. Terraform plans, MSBuild artifacts etc)
$global:BrownserveRepoBuildOutputDirectory = $BrownserveRepoBuildOutputDirectory | Convert-Path
# Used to store any downloaded/copied binaries required for builds, cmdlets like Get-Vault make use of this variable
$global:BrownserveRepoBinaryDirectory = $BrownserveRepoBinaryDirectory | Convert-Path
# Paket/nuget will restore their dependencies to this directory, case sensitive on Linux
$global:BrownserveRepoNugetPackagesDirectory = $BrownserveRepoNugetPackagesDirectory | Convert-Path
# Paket will restore certain types of dependencies to this directory, case sensitive on Linux
$global:BrownserveRepoPaketFilesDirectory = $BrownserveRepoPaketFilesDirectory | Convert-Path


# We use paket for managing our dependencies and we get that via dotnet
Push-Location
Set-Location $Global:BrownserveRepoRootDirectory
Write-Verbose "Restoring dotnet tools"
$DotnetOutput = & dotnet tool restore
if ($LASTEXITCODE -ne 0)
{
    Pop-Location
    $DotnetOutput
    throw "dotnet tool restore failed"
}

Write-Verbose "Installing paket dependencies"
$PaketOutput = & dotnet paket install
if ($LASTEXITCODE -ne 0)
{
    Pop-Location
    $PaketOutput
    throw "Failed to install paket dependencies"
}
Pop-Location

# If Brownserve.PSTools is already loaded in this session (e.g. it's installed globally) we need to unload it
# This ensures only the expected version is available to us
if ((Get-Module 'Brownserve.PSTools'))
{
    try
    {
        Write-Warning "The Brownserve.PSTools module is already loaded in this PSSession, this will be unloaded to Ensure the correct version for this repository is used"
        Write-Verbose "Unloading Brownserve.PSTools"
        Remove-Module 'Brownserve.PSTools' -Force -Confirm:$false -Verbose:$False
    }
    catch
    {
        throw "Failed to unload Brownserve.PSTools.`n$($_.Exception.Message)"
    }
}
# Import the downloaded version of Brownserve.PSTools
try
{
    Write-Verbose "Importing Brownserve.PSTools module"
    Import-Module (Join-Path $Global:BrownserveRepoNugetPackagesDirectory 'Brownserve.PSTools' 'tools', 'Brownserve.PSTools.psd1') -Force -Verbose:$false
}
catch
{
    throw "Failed to import Brownserve.PSTools.`n$($_.Exception.Message)"
}

# Load the module from the "Module" directory
try
{
    Write-Verbose "Loading module from '$($Global:BrownserveModuleDirectory)'"
    Get-ChildItem $Global:BrownserveModuleDirectory -Filter '*.psm1' -Recurse | Foreach-Object {
        Import-Module $_ -Force -Verbose:$false
    }
}
catch
{
    throw "Failed to import module.`n$($_.Exception.Message)"
}

# The PackageManagement module needs to be loaded for Save-Module to function without being overly verbose
if (!(Get-Module 'PackageManagement'))
{
    try
    {
        Import-Module 'PackageManagement' -ErrorAction 'Stop' -Verbose:$False
    }
    catch
    {
        throw "Failed to import the 'PackageManagement' module.$($_.Exception.Message)"
    }
}

<#
    Some cmdlets make use of the platyPS module so ensure it is available
    Unfortunately due to https://github.com/PowerShell/platyPS/issues/592 we cannot load this at the same time as powershell-yaml.
    This should be fixed in a later v2 release but v2 is incredibly buggy at the moment and often fails with unhelpful errors.
    So we download the module and set a special variable to its path.
#>
try
{
    Write-Verbose 'Downloading platyPS module'
    Save-Module 'platyPS' -Repository PSGallery -Path $Global:BrownserveRepoNugetPackagesDirectory -ErrorAction 'Stop'
    # DON'T import the module, set a well known variable that we can use later on.
    $Global:BrownserveRepoPlatyPSPath = Get-ChildItem (Join-Path $Global:BrownserveRepoNugetPackagesDirectory -ChildPath 'platyPS') -Filter 'platyPS.psd1' -Recurse
    if (!$Global:BrownserveRepoPlatyPSPath)
    {
        throw 'Failed to find downloaded PlatyPS'
    }
}
catch
{
    throw "Failed to download the platyPS module.`n$($_.Exception.Message)"
}

# Some cmdlets make use of the powershell-yaml module so ensure it is available, we don't auto-load it to avoid clashing with platyPS
try
{
    Write-Verbose 'Downloading powershell-yaml module'
    Save-Module 'powershell-yaml' -Repository PSGallery -Path $Global:BrownserveRepoNugetPackagesDirectory -ErrorAction 'stop'
    $Global:BrownserveRepoPowerShellYAMLPath = Get-ChildItem (Join-Path $Global:BrownserveRepoNugetPackagesDirectory -ChildPath 'powershell-yaml') -Filter 'powershell-yaml.psd1' -Recurse
    if (!$Global:BrownserveRepoPowerShellYAMLPath)
    {
        throw 'Failed to find powershell-yaml module after download'
    }
}
catch
{
    throw "Failed to download the powershell-yaml module.`n$($_.Exception.Message)"
}

# This repo makes use of Invoke-Build/Pester to run our builds so we need to import them.
try
{
    # Both modules should have been grabbed from nuget by paket, we simply need to import them
    Write-Verbose 'Importing Invoke-Build'
    Join-Path $Global:BrownserveRepoNugetPackagesDirectory 'Invoke-Build' -AdditionalChildPath 'tools', 'InvokeBuild.psd1' | Import-Module -Force -Verbose:$false
    Write-Verbose 'Importing Pester'
    Join-Path $Global:BrownserveRepoNugetPackagesDirectory 'Pester' -AdditionalChildPath 'tools', 'Pester.psd1' | Import-Module -Force -Verbose:$False
}
catch
{
    throw "Failed to import build/test modules.`n$($_.Exception.Message)"
}

<# 
    Sometimes packages we install from Paket/NuGet may already exist on the system, so we set aliases to ensure we only use the local versions
    However aliases are only recognised by _this_ PowerShell session, so if we start another process or call a native command then it won't work.
    Therefore we can choose to set a Global variable that we can use to pass to child processes
#>
try
{    $Path = Get-ChildItem $global:BrownserveRepoNugetPackagesDirectory -Recurse -Filter 'NuGet.exe'
    if (!$Path)
    {
        throw "Failed to find local path to 'NuGet.exe'"
    }
    if ($Path.Count -gt 1)
    {
        throw "Too many paths returned for 'NuGet.exe' expected 1, got $($Path.Count)"
    }
    Set-Alias -Name 'nuget' -Value $Path -Scope Global
    $Global:BrownserveNugetPath = (Get-Command 'nuget').Definition
}
catch
{
    throw "Failed to set aliases.`n$($_.Exception.Message)"
}


# Place any custom code below, this will be preserved whenever you update your _init script
### Start user defined _init steps
$Global:BrownserveRepoModulePath = Join-Path $Global:BrownserveRepoRootDirectory 'Module' 'Brownserve.PuppetModulePSTools.psm1' # Cannot currently load PlatyPS and Powershell-Yaml, will need to wait for PlatyPS to push a new version of v2 to PSGallery which includes the Nov22 changes: # https://github.com/PowerShell/platyPS/issues/481 $GalleryModules = @('PlatyPS') $GalleryModules | ForEach-Object {     $ModulePath = $null     $ModulePath = Get-Module $_ -ListAvailable -ErrorAction 'SilentlyContinue'     try     {         if (!$ModulePath)         {             Write-Verbose "$_ not available locally, downloading"             Save-Module `                 -Name $_ `                 -Repository PSGallery `                 -Path $Global:BrownserveRepoNugetPackagesDirectory `                 -Force `                 -ErrorAction 'Stop'             $ModulePath = Get-ChildItem (Join-Path $Global:BrownserveRepoNugetPackagesDirectory $_) -Filter "$_.psd1" -Recurse             if (!$ModulePath)             {                 Write-Error "Failed to find $_ module after download."             }         }         Import-Module $ModulePath -Force -ErrorAction 'stop'     }     catch     {         throw "Failed to load additional PSGallery modules.`n$($_.Exception.Message)"     } } try {     Import-Module $Global:BrownserveRepoModulePath -Force -ErrorAction 'Stop' } catch {     throw "Failed to import Brownserve.PuppetModulePSTools.`n$($_.Exception.Message)" }
### End user defined _init steps

# If we're not suppressing output then we'll pipe out a list of cmdlets that are now available to the user along with
# Their synopsis. 
if (!$SuppressOutput)
{
    if ($Global:BrownserveCmdlets)
    {
        Write-Host "The following modules have been loaded and their functions are now available:`n"
        $Global:BrownserveCmdlets | ForEach-Object {
            Write-Host "$($_.Module):" -ForegroundColor Yellow
            $_.Cmdlets | ForEach-Object {
                Write-Host "    $($_.Name) " -ForegroundColor Magenta -NoNewline; Write-Host "|  $($_.Synopsis)" -ForegroundColor Blue
            }
            ''
        }
        Write-Host "For more information please use the 'Get-Help <command-name>' command`n"
    }
}