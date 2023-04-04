<#
.SYNOPSIS
    This cmdlet will build all the files needed to run Kitchen against a Puppet module.
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
function Build-KitchenTestsFromTemplates
{
    [CmdletBinding()]
    param
    (
        # The name of the module that the tests will be created for
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,

        # The platforms (OSes) that kitchen should test against
        [Parameter(Mandatory = $true)]
        [KitchenPlatform[]]
        $TestPlatforms,

        # Any test suites that should be created
        [Parameter(Mandatory = $false)]
        [KitchenSuite[]]
        $TestSuites,

        # Skip creating the default suites if we are passing in our own
        [Parameter(Mandatory = $false)]
        [switch]
        $SkipDefaultSuiteCreation
    )
    
    begin
    {
        # The return should be an array of the files we wish to create
        $Return = @()
    }
    
    process
    {
        <# 
            Start by building the manifest we'll use for kitchen tests.
            Right now we only ever use one so we just use default settings, but the cmdlet is flexible if we decided to
            expand it, we'd simply need to param this cmdlet.
        #>
        try
        {
            $ManifestTemplate = Build-KitchenManifestFromTemplate -ModuleName $ModuleName -ErrorAction 'Stop'
            if ($ManifestTemplate)
            {
                $Return += $ManifestTemplate
            }
            else
            {
                Write-Error 'Build-KitchenManifestFromTemplate returned an empty object.'
            }
        }
        catch
        {
            throw "Failed to create Kitchen manifest.`n$($_.Exception.Message)"
        }
        # Now build up the Hiera Kitchen will use, again we only ever create one so we just use the defaults
        try
        {
            $HieraTemplate = Build-KitchenHieraDataFromTemplate -ErrorAction 'Stop'
            if ($HieraTemplate)
            {
                $Return += $HieraTemplate
            }
            else
            {
                Write-Error 'Build-KitchenHieraDataFromTemplate returned an empty object.'
            }
        }
        catch
        {
            throw "Failed to create Kitchen Hiera.`n$($_.Exception.Message)"
        }
        <# 
            As it stands Windows/Linux require different helper files to perform spec tests correctly which are stored in the
            root of this repo.
            So we check the Operating Systems that we are going to test against and ensure that we at least have one set of
            tests per kernel.
        #>
        if ($TestPlatforms.OperatingSystem -like '*windows*')
        {
            try
            {
                $WindowsAcceptance = Build-KitchenAcceptanceTestFromTemplate `
                    -Helper 'windows' `
                    -SpecFileName 'windows_tests_spec.rb'
                if ($WindowsAcceptance)
                {
                    $Return += $WindowsAcceptance
                }
                else
                {
                    Write-Error 'Build-KitchenAcceptanceTestFromTemplate returned an empty object.'
                }
                # Only create our default suite it if we've not already specified it manually and we actually want to.
                if ($TestSuites.SuiteName -notcontains 'windows_tests')
                {
                    if ($SkipDefaultSuiteCreation -eq $true)
                    {
                        <# 
                            We only warn as it feels a bit heavy handed to throw given that it may be intentional depending on what
                            other tests have been declared.
                            Might be worth doing a check here in the future to see if we do want to continue or not?
                        #>
                        Write-Warning 'No default test suites for Windows seem to have been defined.'
                    }
                    else
                    {
                        $TestSuites += @{
                            SuiteName         = 'windows_tests'
                            IncludedPlatforms = '/windows/'
                        }
                    }
                }
            }
            catch
            {
                throw "Failed to build Windows spec tests.`n$($_.Exception.Message)"
            }
        }
        # Currently Ubuntu is the only Linux platform we test against but this logic may need to change in future if we introduce more
        if ($TestPlatforms.OperatingSystem -like '*ubuntu*')
        {
            try
            {
                $LinuxAcceptance = Build-KitchenAcceptanceTestFromTemplate `
                    -Helper 'linux' `
                    -SpecFileName 'linux_tests_spec.rb'
                if ($LinuxAcceptance)
                {
                    $Return += $LinuxAcceptance
                }
                else
                {
                    Write-Error 'Build-KitchenAcceptanceTestFromTemplate returned an empty object.'
                }
                # Only create our default suite it if we've not already specified it manually
                if ($TestSuites.SuiteName -notcontains 'linux_tests')
                {
                    if ($SkipDefaultSuiteCreation -eq $true)
                    {
                        <# 
                            We only warn as it feels a bit heavy handed to throw given that it may be intentional depending on what
                            other tests have been declared.
                            Might be worth doing a check here in the future to see if we do want to continue or not?
                        #>
                        Write-Warning 'No default test suites for Linux seem to have been defined.'
                    }
                    else
                    {
                        $TestSuites += @{
                            SuiteName         = 'linux_tests'
                            ExcludedPlatforms = '/windows/'
                        }
                    }
                }
            }
            catch
            {
                throw "Failed to build Linux spec tests.`n$($_.Exception.Message)"
            }
        }

        # At this point we should be able to tell whether we've got any test suites or not, we'll need some so throw if not
        if (!$TestSuites)
        {
            throw 'No test suites have been defined and -SkipDefaultSuiteCreation has been passed.'
        }

        <# 
            Now we'll build 2 individual blocks of the .kitchen.yml file; suites and platforms.
            The output of these is then passed into the cmdlet that will build the finalized .kitchen.yml
        #>
        try
        {
            $SuitesBlock = Build-KitchenSuiteFromTemplate -Suites $TestSuites -ErrorAction 'Stop'
            if (!$SuitesBlock)
            {
                Write-Error 'Build-KitchenSuiteFromTemplate returned an empty object.'
            }
        }
        catch
        {
            throw "Failed to create Kitchen suites.`n$($_.Exception.Message)"
        }
        try
        {
            $PlatformBlock = Build-KitchenPlatformFromTemplate -Platforms $TestPlatforms
            if (!$PlatformBlock)
            {
                Write-Error 'Build-KitchenPlatformFromTemplate returned an empty object.'
            }
        }
        catch
        {
            throw "Failed to create Kitchen platforms.`n$($_.Exception.Message)"
        }
        # No we can build the .kitchen.yml file
        try
        {
            $KitchenYAML = Build-KitchenYAMLFromTemplate `
                -PlatformBlock $PlatformBlock `
                -SuiteBlock $SuitesBlock `
                -KitchenManifestFileName 'kitchen.pp'
            if (!$KitchenYAML)
            {
                Write-Error 'Build-KitchenYAMLFromTemplate returned an empty object.'
            }
            else
            {
                $Return += $KitchenYAML
            }
        }
        catch
        {
            throw "Failed to build Kitchen YAML.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($Return -ne @())
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}