<#
.SYNOPSIS
    Simple wrapper to create a hiera file for a node
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


function New-NodeHiera
{
    [CmdletBinding()]
    param
    (
        # Collection of objects to process into a hiera file
        [Parameter(
            Mandatory = $false
        )]
        [hashtable]
        $Data,

        # An optional header to use for the file
        [Parameter(Mandatory = $false)]
        [string[]]
        $Header = @(
            "This file contains the test data for kitchen to use",
            "you may wish to override settings that aren't compatible with acceptance tests"
        ),

        # Special hidden parameter to allow for setting default values via config file
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $ConfigFileKey,
        
        # Special hidden parameter to allow for setting default values via config file
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $ConfigFile
    )
    
    begin
    {
        
    }
    
    process
    {
        $YAML = "---`n"
        if ($ConfigFile)
        {
            if (!$ConfigFileKey)
            {
                throw 'ConfigFileKey must be specified when using ConfigFile'
            }
            $Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json -AsHashtable
            if (!$Config.$ConfigFileKey)
            {
                throw "ConfigFile '$ConfigFile' has no key named '$ConfigFileKey'"
            }
            if ($Data)
            {
                $Data = $Data + $Config.$ConfigFileKey.Data
            }
            else
            {
                $Data = $Config.$ConfigFileKey.Data
            }
            if ($Config.$ConfigFileKey.Header)
            {
                $Header = $Config.$ConfigFileKey.Header
            }
        }
        else
        {
            if ($ConfigFileKey)
            {
                throw "ConfigFileKey was passed without any ConfigFile"
            }
        }
        if ($Header)
        {
            $YAML += $Header | ForEach-Object { 
                if ($_ -match '^\s*#')
                {
                    $_
                }
                else
                {
                    "# $_"
                }
            } | Out-String
            $YAML += "`n"
        }
        if (!$Data)
        {
            # There are situations where we might not have any data to process so we don't want to throw an error
            Write-Verbose 'No data provided'
        }
        else
        {
            try
            {
                $YAML += $Data | Invoke-ConvertToYaml
            }
            catch
            {
                throw "Failed to convert data to YAML.`n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        if ($YAML)
        {
            return $YAML
        }
        else
        {
            return $null
        }
    }
}