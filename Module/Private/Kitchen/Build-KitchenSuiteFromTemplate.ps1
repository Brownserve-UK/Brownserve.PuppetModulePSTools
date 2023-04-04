<#
.SYNOPSIS
    Creates a test suite block from a given template to use in a Kitchen test configuration
.DESCRIPTION
    Creates a test suite block from a given template to use in a Kitchen test configuration
.EXAMPLE
    New-KitchenSuiteFromTemplate -SuiteName 'linux_tests' -SpecFileName 'default_linux_spec.rb' 

    This would return a block of text that can be used in kitchen suite configuration
#>
function Build-KitchenSuiteFromTemplate
{
    [CmdletBinding(DefaultParameterSetName = 'default')]
    param
    (
        # The name of the suite
        [Parameter(Mandatory = $true, ParameterSetName = 'default')]
        [string]
        $SuiteName,

        # The name of the spec file to use for this test
        [Parameter(Mandatory = $false)]
        [string]
        $SpecFileName = "$($SuiteName)_spec.rb",

        # An optional list of platforms to include for this suite
        [Parameter(Mandatory = $false)]
        [string[]]
        $IncludedPlatforms,

        # An optional list of platforms to exclude for this suite
        [Parameter(Mandatory = $false)]
        [string[]]
        $ExcludedPlatforms,

        # The type of suite template to use to create the block
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateFile = 'default.yaml',

        # The directory that houses the template files
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateDirectory = (Join-Path $Script:PuppetTemplateDirectory 'kitchen' 'suites'),

        # Special hidden parameter for when we know what we're doing.
        # We don't support piping as it applies param validation in the process block which is too late when
        # we have malformed data
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'suites', DontShow)]
        [ValidateNotNullOrEmpty()]
        [KitchenSuite[]]
        $Suites
    )
    
    begin
    {
        try
        {
            $SuiteTemplate = Get-Content (Join-Path $TemplateDirectory $TemplateFile) -Raw -ErrorAction 'Stop'
        }
        catch
        {
            throw "Unable to load template '$TemplateFile'.`n$($_.Exception.Message)"
        }
        $Return = @()
    }
    
    process
    {
        if (!$Suites)
        {
            # Create a temp hash as $Suites is predefined param and is as such inflexible
            $TempHash = @{
                SuiteName    = $SuiteName
                SpecFileName = $SpecFileName
            }
            if ($IncludedPlatforms)
            {
                $TempHash.Add('IncludedPlatforms', $IncludedPlatforms)
            }
            if ($ExcludedPlatforms)
            {
                $TempHash.Add('ExcludedPlatforms', $ExcludedPlatforms)
            }
            $Suites = $TempHash
        }
        Write-Debug "TestSuites:$($TestSuites | Out-String)"
        
        foreach ($Suite in $Suites)
        {
            $CurrentTemplate = $SuiteTemplate
            $CurrentTemplate = $CurrentTemplate -replace '<SUITE_NAME>', $Suite.SuiteName
            $CurrentTemplate = $CurrentTemplate -replace '<SPEC_FILE>', $Suite.SpecFileName
            if ($Suite.IncludedPlatforms)
            {
                $CurrentTemplate = $CurrentTemplate + "`n    includes: [$($Suite.IncludedPlatforms  -join ",")]"
            }
            if ($Suite.ExcludedPlatforms)
            {
                $CurrentTemplate = $CurrentTemplate + "`n    excludes: [$($Suite.ExcludedPlatforms  -join ",")]"
            }
            $Return += $CurrentTemplate
        }
    }
    
    end
    {
        if ($Return -ne @())
        {
            Write-Debug "Build-KitchenSuiteFromTemplate returns:`n$($Return | Out-String)"
            return ($Return | Out-String) # Make sure we return a string so it can be ingested easily elsewhere.
        }
        else
        {
            return $null
        }
    }
}