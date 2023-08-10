function New-AcceptanceTest
{
    [CmdletBinding()]
    param
    (
        # Any requirements
        [Parameter(Mandatory = $false)]
        [string[]]
        $Requirements,

        # Any local requirements
        [Parameter(Mandatory = $false)]
        [string[]]
        $RelativeRequirements,

        # Any additional tests that should be added
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Tests,

        # Whether or not to use helper files
        [Parameter(
            Mandatory = $false
        )]
        [bool]
        $RequireHelperFile = $true,

        # The relative path to the helper file
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $HelperFileName,

        # The path to where the helper file lives
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $HelperFilePath,

        # The key to use in the config file for a given acceptance test
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $ConfigFileKey,

        # Special param when using config files to look up data
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $HelperFilePathKey,

        # Special param when using config files to look up data
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $HelperFileNameKey,

        # The special config file to use
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
        if ($ConfigFile)
        {
            if (!$ConfigFileKey)
            {
                throw 'No config file key provided'
            }
            try
            {
                $Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json -AsHashtable
            }
            catch
            {
                throw "Failed to load config file.`n$($_.Exception.Message)"
            }
            if (!$Config.$ConfigFileKey)
            {
                Write-Debug "Config:`n$($Config | Out-String)"
                throw "ConfigFile '$ConfigFile' has no key named '$ConfigFileKey'"
            }
        }
        else
        {
            if ($ConfigFileKey)
            {
                throw 'ConfigFileKey provided but no ConfigFile was specified.'
            }
        }
        <#
            Special logic for loading spec helper files.
            These live in different places depending on if we're creating a standalone module or one that lives in an
            environment.
            We allow a user to specify these locations in the config file if they want (or override them on a per-acceptance test basis)
        #>
        if ($RequireHelperFile -eq $true)
        {
            # First check if the user has passed one in for this acceptance test, if so then we'll just use that and skip this logic
            if (!$HelperFilePath)
            {
                # If they haven't passed one in and they are passing in a config file we'll try to look it up from there
                if ($Config)
                {
                    # First see if the user has specified a path for this acceptance test, if so use that.
                    if ($Config.$ConfigFileKey.HelperFilePath)
                    {
                        $HelperFilePath = $Config.$ConfigFileKey.HelperFilePath
                    }
                    # If not then we'll try to look up from a list
                    else
                    {
                        if ($HelperFilePathKey)
                        {
                            Write-Verbose "Attempting to look up '$HelperFilePathKey' from config."
                            if ($Config.HelperFilePath.$HelperFilePathKey)
                            {
                                $HelperFilePath = $Config.HelperFilePath.$HelperFilePathKey
                            }
                            else
                            {
                                throw "Cannot find HelperFilePath configuration for '$HelperFilePathKey' in '$ConfigFile'"
                            }
                        }
                    }
                }
                if (!$HelperFilePath)
                {
                    # If all the above fails (without error) then set a default
                    Write-Verbose "Exhausted all methods of determining HelperFilePath, using default"
                    $HelperFilePath = '../'
                }
            }
            else
            {
                Write-Verbose "HelperFilePath passed in: $HelperFilePath"
            }
            # Same logic for the filename too
            if (!$HelperFileName)
            {
                if ($Config)
                {
                    if ($Config.$ConfigFileKey.HelperFileName)
                    {
                        $HelperFileName = $Config.$ConfigFileKey.HelperFileName
                    }
                    else
                    {
                        if ($HelperFileNameKey)
                        {
                            if ($Config.HelperFileName.$HelperFileNameKey)
                            {
                                $HelperFileName = $Config.HelperFileName.$HelperFileNameKey
                            }
                            else
                            {
                                throw "Cannot find HelperFileName configuration for '$HelperFileNameKey' in '$ConfigFile'"
                            }
                        }
                    }
                }
                if (!$HelperFileName)
                {
                    # If all the above fails (without error) then set a default
                    Write-Verbose "Exhausted all methods of determining HelperFileName, using default"
                    $HelperFileName = 'spec_helper'
                }
            }
            Write-Debug "HelperFilePath: $HelperFilePath"
            Write-Debug "HelperFileName: $HelperFileName"
            $HelperFile = (Join-Path $HelperFilePath $HelperFileName)
        }
        $Content = "# Encoding: utf-8`n`r`n"
        if (!$RelativeRequirements)
        {
            if ($Config.$ConfigFileKey.RelativeRequirements)
            {
                $RelativeRequirements = $Config.$ConfigFileKey.RelativeRequirements
            }
        }
        if (!$Requirements)
        {
            if ($Config.$ConfigFileKey.Requirements)
            {
                $Requirements = $Config.$ConfigFileKey.Requirements
            }
        }
        if (!$Tests)
        {
            if ($Config.$ConfigFileKey.Tests)
            {
                $Tests = $Config.$ConfigFileKey.Tests
            }
        }
        if ($HelperFile)
        {
            if ($RelativeRequirements)
            {
                $RelativeRequirements += $HelperFile
            }
            else
            {
                $RelativeRequirements = $HelperFile
            }
        }
        if ($RelativeRequirements.Count -gt 0)
        {
            $RelativeRequirements | ForEach-Object {
                $Content += "require_relative '$_'`n"
            }
            $Content += "`n"
        }
        if ($Requirements.Count -gt 0)
        {
            $Requirements | ForEach-Object {
                $Content += "require '$_'`n"
            }
            $Content += "`n"
        }
        $Content += "# Write your tests below`n"
        if ($Tests.Count -gt 0)
        {
            $Content += "`n"
            $Tests | ForEach-Object {
                $Content += "$_`n"
            }
            $Content += "`n"
        }
    }
    
    end
    {
        return $Content
    }
}