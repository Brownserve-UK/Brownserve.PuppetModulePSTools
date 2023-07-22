<#
.SYNOPSIS
    A PowerShell module for creating, testing and publishing Brownserve Puppet modules
#>
#Requires -Version 6.0
#Requires -Module Brownserve.PSTools
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

# We use some special variables for working out what cmdlets are compatible with a users systems
$PublicCmdlets = @()

# Dot source our private functions so they are available for our public functions to use (but only if we have some private functions!)
$PrivatePath = Join-Path $PSScriptRoot -ChildPath 'Private'
if (Test-Path $PrivatePath)
{
    $PrivatePath |
        Resolve-Path |
            Get-ChildItem -Filter *.ps1 -Recurse |
                ForEach-Object {
                    . $_.FullName
                }
}

# We should always have public functions, so we'll dot source those and export them
Join-Path $PSScriptRoot -ChildPath 'Public' |
    Resolve-Path |
        Get-ChildItem -Filter *.ps1 -Recurse |
            ForEach-Object {
                . $_.FullName
                Export-ModuleMember $_.BaseName
                $PublicCmdlets += Get-Help $_.BaseName
            }

# Place any custom code for your module ONLY in the space below
# this will ensure it is preserved when the module is updated using Update-BrownservePowerShellModule
### Start user defined module steps
$Script:SupportedOSConfigurationFile = Join-Path $PrivatePath 'SupportedOS_Defaults.jsonc' | Convert-Path
$script:DefaultPuppetMajorVersion = 6 # set this here so we only have one place to change it
### End user defined module steps

<# 
    If our special variable exists then add these cmdlets to said variable so we can output their summary later on.
    Unfortunately just checking for the existence of the variable isn't enough as if it's blank PowerShell seems to treat it as null :(
#>
if ($Global:BrownserveCmdlets -is 'System.Array')
{
    $Global:BrownserveCmdlets += @{
        Module  = "$($MyInvocation.MyCommand)"
        Cmdlets = $PublicCmdlets
    }
}
else
{
    Write-Host "The following cmdlets from $($MyInvocation.MyCommand) are now available for use:" -ForegroundColor White
    $PublicCmdlets | ForEach-Object {
        Write-Host "    $($_.Name) " -ForegroundColor Magenta -NoNewline; Write-Host "|  $($_.Synopsis)" -ForegroundColor Blue
    }
    Write-Host "For more information please use the 'Get-Help <command-name>' command`n"
}

<#
    The config directory is used to store various default configurations for our cmdlets to reference
#>
$Script:ModuleConfigDirectory = Join-Path $PrivatePath '.config'