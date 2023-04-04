<#
.SYNOPSIS
    Adds a module layer hiera configuration to a given Puppet module
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function New-PuppetModuleHieraConfiguration
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
        try
        {
            $ToCreate = @()
            # We run the cmdlet twice - once to create the hiera.yaml and once to create the data/common.yaml.
            $ToCreate += Build-ModuleHieraFromTemplate `
                -HieraFilePath ('hiera.yaml') `
                -Template 'hiera.yaml'
            $ToCreate += Build-ModuleHieraFromTemplate `
                -HieraFilePath (Join-Path 'data' 'common.yaml') `
                -Template 'common.yaml'
        }
        catch
        {
            throw $_.Exception.Message
        }
        # Now that we've built everything we need we can start writing out to disk
        $DataDirectory = Join-Path $PuppetModulePath 'data'
        try
        {
            # It's ok if the directory exists providing no files exist below it
            if (!(Test-Path $DataDirectory))
            {
                New-Item $DataDirectory -ItemType Directory -Force:$Force -ErrorAction 'Stop'
            }
        }
        catch
        {
            throw "Failed to create data directory.`n$($_.Exception.Message)"
        }
        try
        {
            # By default New-Item will complain if files exist and -Force isn't passed
            $ToCreate | ForEach-Object {
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