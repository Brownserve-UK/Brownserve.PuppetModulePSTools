<#
.SYNOPSIS
    Initializes this repository
#>
# We require 6.0+ due to using newer features of PowerShell
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
# Holds all build related configuration along with this _init script
$Global:BrownserveRepoBuildDirectory = Join-Path $global:BrownserveRepoRootDirectory '.build' | Convert-Path
# Used to store any custom code/scripts/modules
$Global:BrownserveRepoCodeDirectory = Join-Path $global:BrownserveRepoRootDirectory '.build' 'code' | Convert-Path


# Get the name of the repo
$Global:BrownserveRepoName = Split-Path $Global:BrownserveRepoRootDirectory -Leaf

# Set-up our ephemeral paths, that is those that will be destroyed and then recreated each time this script is called
$EphemeralPaths = @(
    ($BrownserveRepoNugetPackagesDirectory = Join-Path $Global:BrownserveRepoRootDirectory 'packages'),
    ($BrownserveRepoTempDirectory = Join-Path $global:BrownserveRepoRootDirectory '.tmp'),
    ($BrownserveRepoLogDirectory = Join-Path $global:BrownserveRepoRootDirectory '.tmp' 'logs'),
    ($BrownserveRepoBuildOutputDirectory = Join-Path $global:BrownserveRepoRootDirectory '.tmp' 'output'),
    ($BrownserveRepoBinaryDirectory = Join-Path $global:BrownserveRepoRootDirectory '.tmp' 'bin')

)
try
{
    Write-Verbose 'Recreating ephemeral paths'
    $EphemeralPaths | ForEach-Object {
        if ((Test-Path $_))
        {
            Remove-Item $_ -Recurse -Force | Out-Null
        }
        New-Item $_ -ItemType Directory -Force | Out-Null
    }
}
catch
{
    Write-Error $_.Exception.Message
    break
}

# Now that the ephemeral paths definitely exist we are free to set their global variables
# This is the directory that paket downloads stuff into
$Global:BrownserveRepoNugetPackagesDirectory = $BrownserveRepoNugetPackagesDirectory | Convert-Path 
# Used to store temporary files created for builds/tests
$global:BrownserveRepoTempDirectory = $BrownserveRepoTempDirectory | Convert-Path
# Used to store build logs and output from Invoke-NativeCommand
$global:BrownserveRepoLogDirectory = $BrownserveRepoLogDirectory | Convert-Path
# Used to store any output from builds (e.g. Terraform plans, MSBuild artifacts etc)
$global:BrownserveRepoBuildOutputDirectory = $BrownserveRepoBuildOutputDirectory | Convert-Path
# Used to store any downloaded binaries required for builds, cmdlets like Get-Vault make use of this variable
$global:BrownserveRepoBinaryDirectory = $BrownserveRepoBinaryDirectory | Convert-Path


# We use paket for managing our dependencies and we get that via dotnet
Write-Verbose 'Restoring dotnet tools'
$DotnetOutput = & dotnet tool restore
if ($LASTEXITCODE -ne 0)
{
    $DotnetOutput
    throw 'dotnet tool restore failed'
}

Write-Verbose 'Installing paket dependencies'
$PaketOutput = & dotnet paket install
if ($LASTEXITCODE -ne 0)
{
    $PaketOutput
    throw 'Failed to install paket dependencies'
}

# If Brownserve.PSTools is already loaded in this session (e.g. it's installed globally) we need to unload it
# This ensures only the expected version is available to us
if ((Get-Module 'Brownserve.PSTools'))
{
    try
    {
        Write-Verbose 'Unloading Brownserve.PSTools'
        Remove-Module 'Brownserve.PSTools' -Force -Confirm:$false
    }
    catch
    {
        throw "Failed to unload Brownserve.PSTools.`n$($_.Exception.Message)"
    }
}
# Import the downloaded version of Brownserve.PSTools
try
{
    Write-Verbose 'Importing Brownserve.PSTools module'
    Import-Module (Join-Path $Global:BrownserveRepoNugetPackagesDirectory 'Brownserve.PSTools' 'tools', 'Brownserve.PSTools.psd1') -Force -Verbose:$false
}
catch
{
    throw "Failed to import Brownserve.PSTools.`n$($_.Exception.Message)"
}

# Find and load any custom PowerShell modules we've written for this repo
try
{
    Get-ChildItem $global:BrownserveRepoCodeDirectory -Filter '*.psm1' -Recurse | ForEach-Object {
        Import-Module $_ -Force -Verbose:$false
    }
}
catch
{
    throw "Failed to import custom modules.`n$($_.Exception.Message)"
}

# Place any custom code below, this will be preserved whenever you update your _init script
### Start user defined _init steps
$Global:BrownserveRepoModulePath = Join-Path $Global:BrownserveRepoRootDirectory 'Module' 'Brownserve.PuppetModulePSTools.psm1'
# Cannot currently load PlatyPS and Powershell-Yaml, will need to wait for PlatyPS to push a new version of v2 to PSGallery which includes the Nov22 changes:
# https://github.com/PowerShell/platyPS/issues/481
$GalleryModules = @('PlatyPS')
$GalleryModules | ForEach-Object {
    $ModulePath = $null
    $ModulePath = Get-Module $_ -ListAvailable -ErrorAction 'SilentlyContinue'
    try
    {
        if (!$ModulePath)
        {
            Write-Verbose "$_ not available locally, downloading"
            Save-Module `
                -Name $_ `
                -Repository PSGallery `
                -Path $Global:BrownserveRepoNugetPackagesDirectory `
                -Force `
                -ErrorAction 'Stop'
            $ModulePath = Get-ChildItem (Join-Path $Global:BrownserveRepoNugetPackagesDirectory $_) -Filter "$_.psd1" -Recurse
            if (!$ModulePath)
            {
                Write-Error "Failed to find $_ module after download."
            }
        }
        Import-Module $ModulePath -Force -ErrorAction 'stop'
    }
    catch
    {
        throw "Failed to load additional PSGallery modules.`n$($_.Exception.Message)"
    }
}
try
{
    Import-Module $Global:BrownserveRepoModulePath -Force -ErrorAction 'Stop'
}
catch
{
    throw "Failed to import Brownserve.PuppetModulePSTools.`n$($_.Exception.Message)"
}
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