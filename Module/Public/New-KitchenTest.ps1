<#
.SYNOPSIS
    Adds a new Kitchen test configuration to a given Puppet module
.DESCRIPTION
    Adds a new Kitchen test configuration to a given Puppet module
.EXAMPLE
    New-KitchenTest

    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function New-KitchenTest
{
    [CmdletBinding()]
    param
    (
        # The path to the module to add the kitchen tests to
        [Parameter(Mandatory = $true)]
        [string]
        $PuppetModulePath,

        # The name of the module to create the tests against
        [Parameter(Mandatory = $false)]
        [string]
        $PuppetModuleName = (Split-Path $PuppetModulePath -Leaf),

        # The operating systems that these tests should test against
        [Parameter(Mandatory = $false)]
        [TestOperatingSystems[]]
        $TestOperatingSystems = @('ubuntu_server', 'windows_server_core', 'windows_server_standard'),

        # The OS release to test against
        [Parameter(Mandatory = $false)]
        [OSRelease[]]
        $TestOperatingSystemReleases = 'stable',

        # The version of Puppet to test against
        [Parameter(Mandatory = $false)]
        [PuppetAgentVersion]
        $PuppetAgentVersion = 'latest',

        # The platforms (OSes) that kitchen should test against
        [Parameter(Mandatory = $false)]
        [KitchenPlatform[]]
        $TestPlatforms,

        # Any test suites that should be created alongside the default windows_tests/linux_tests
        [Parameter(Mandatory = $false)]
        [KitchenSuite[]]
        $TestSuites,

        # Forces file creation even if they already exist at that location
        [Parameter()]
        [switch]
        $Force
    )
    
    begin
    {
        try
        {
            Get-Item $PuppetModulePath -ErrorAction 'Stop' | Out-Null
        }
        catch
        {
            throw "Puppet module at '$PuppetModulePath' does not exist"
        }
    }
    
    process
    {
        # If the user hasn't passed in a specific list of test platforms to be created then we'll create our own from
        # the parameters
        if ($null -eq $TestPlatforms)
        {
            Write-Verbose "Using parameters to build test platforms"
            foreach ($OS in $TestOperatingSystems)
            {
                foreach ($Release in $TestOperatingSystemReleases)
                {
                    $TestPlatforms += [KitchenPlatform]@{
                        OperatingSystem    = $OS
                        OSRelease          = $Release
                        PuppetAgentVersion = $PuppetAgentVersion
                    }
                }
            }
            Write-Debug "Platforms:$($TestPlatforms | Out-string)"
        }
        try
        {
            $KitchenTemplates = Build-KitchenTestsFromTemplates `
                -ModuleName $PuppetModuleName `
                -TestPlatforms $TestPlatforms `
                -TestSuites $TestSuites `
                -ErrorAction 'Stop'
        }
        catch
        {
            throw $_.Exception.Message
        }
        # If we've successfully built the kitchen templates then we can go ahead and start modifying files on disk
        # First create the directory structure
        try
        {
            $SpecDirectory = Join-Path $PuppetModulePath 'spec'
            $ModuleSubDirs = @(
                $SpecDirectory,
                (Join-Path $SpecDirectory 'acceptance'),
                (Join-Path $SpecDirectory 'hieradata'),
                (Join-Path $SpecDirectory 'manifests')
            )
            $ModuleSubDirs | ForEach-Object {
                if ((Test-Path $_) -and ($Force -ne $true))
                {
                    Write-Error "Path already exists '$_'"
                }
                else
                {
                    New-Item $_ -ItemType Directory -ErrorAction 'Stop' -Force:$Force
                }
            }
        }
        catch
        {
            throw "Failed to create subdirectories.`n$($_.Exception.Message)"
        }
        # Now create all the files beneath them
        try
        {
            $KitchenTemplates | ForEach-Object {
                $Path = Join-Path $PuppetModulePath $_.FilePath -ErrorAction 'Stop'
                New-Item `
                    -Path $Path `
                    -ItemType File `
                    -Value $_.Content `
                    -ErrorAction 'Stop' `
                    -Force:$Force
            }
        }
        catch
        {
            throw "Failed to create template file at '$Path'.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}