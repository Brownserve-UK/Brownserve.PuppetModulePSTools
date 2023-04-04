# This class is basically some param validation for the version of Puppet we want to use
class PuppetAgentVersion
{
    $version

    # If we've been passed a string then work out what to do
    PuppetAgentVersion([string]$version)
    {
        if ($version.ToLower() -eq 'latest')
        {
            $this.version = 'latest'
        }
        else
        {
            $this.version = [version]$version
        }
    }

    # This constructor is used to cast a version to a version
    PuppetAgentVersion([version]$version)
    {
        $this.version = [version]$version
    }
}

# This class ensures that our Build-*FromTemplate cmdlets have consistent output
class BuiltTemplate
{
    [string] $FilePath
    [string] $Content

    # Constructor to build from a structured hash
    BuiltTemplate([hashtable]$BuiltTemplate)
    {
        if ($BuiltTemplate.FilePath)
        {
            $this.FilePath = $BuiltTemplate.FilePath
        }
        else
        {
            throw "Cannot form object from given hashtable. Hashtable must contain a key called 'FilePath'"
        }
        if ($BuiltTemplate.Content)
        {
            $this.Content = $BuiltTemplate.Content
        }
        else
        {
            throw "Cannot form object from given hashtable. Hashtable must contain a key called 'Content'"
        }
    }
}

# This helps us to validate any test providers that we use
enum TestProvider
{
    kitchen_vagrant
}

<# 
    When we perform acceptance testing it's often useful to test against multiple versions of an OS especially when
    we're moving between major versions on have multiple nodes running the same code on different OSes.
    We need a way to easily store and identify which operating systems are bleeding edge, current or getting old so
    we can easily test against them, so the following enum are the terms that we'll use to refer to operating system
    releases from here on out.
#>
enum OSRelease
{
    latest
    stable
    legacy
}

<# 
    Again we do a similar thing for Operating Systems that we actually support, this ensures when creating a new OS
    for tests that we define it consistently and in all the right places at once.
#>
enum TestOperatingSystems
{
    ubuntu_server
    windows_server_standard
    windows_server_core
    ubuntu_desktop
    windows_desktop
}

enum KitchenSuiteHelpers
{
    linux
    windows
}

<#
    This class ensures that we have a standard format for Kitchen test suites to make passing them between cmdlets seamless.
    It also ensures any user entered data is in the format we expect with helpful error messages.
#>
class KitchenSuite
{
    [string]$SuiteName
    [string]$SpecFileName
    [string[]]$IncludedPlatforms
    [string[]]$ExcludedPlatforms

    # Currently we only support building this object from a structured hash
    KitchenSuite([hashtable]$KitchenSuite)
    {
        $Name = $KitchenSuite.GetEnumerator() |
            Where-Object { $_.Key -eq 'SuiteName' } |
                Select-Object -ExpandProperty Value
        if (!$Name)
        {
            throw "Cannot form object from given hashtable. Hashtable must contain a key called 'SuiteName'"
        }
        else
        {
            $this.SuiteName = $Name
        }
        $FileName = $KitchenSuite.GetEnumerator() |
            Where-Object { $_.Key -eq 'SpecFileName' } |
                Select-Object -ExpandProperty Value
        if (!$FileName)
        {
            $this.SpecFileName = "$($Name)_spec.rb"
        }
        $Included = $KitchenSuite.GetEnumerator() |
            Where-Object { $_.Key -eq 'IncludedPlatforms' } |
                Select-Object -ExpandProperty Value
        if ($Included)
        {
            $this.IncludedPlatforms = $Included
        }
        $Excluded = $KitchenSuite.GetEnumerator() |
            Where-Object { $_.Key -eq 'ExcludedPlatforms' } |
                Select-Object -ExpandProperty Value
        if ($Excluded)
        {
            $this.ExcludedPlatforms = $Excluded
        }
    }
}

<# 
    This class ensures that we can easily verify our Kitchen Platforms are in the state we expect, this is mostly useful
    when a user decides to specify their own values.
#>
class KitchenPlatform
{
    [String]$PlatformName
    [string]$OperatingSystem
    [string[]]$OSRelease
    [int[]]$MajorPuppetVersion
    $PuppetAgentVersion

    # Currently we only support building this object from a structured hash
    KitchenPlatform([hashtable]$KitchenPlatform)
    {
        $OS = $KitchenPlatform.OperatingSystem
        if ($null -eq $OS)
        {
            throw "Cannot form object from given hashtable. Hashtable must contain a key called 'OperatingSystem'"
        }
        $Releases = $KitchenPlatform.OSRelease
        if ($null -eq $Releases)
        {
            throw "Cannot form object from given hashtable. Hashtable must contain a key called 'OSRelease'"
        }
        $PA = $KitchenPlatform.PuppetAgentVersion
        if ($null -eq $PA)
        {
            throw "Cannot form object from given hashtable. Hashtable must contain a key called 'PuppetAgentVersion'"
        }
        $PMV = $KitchenPlatform.PuppetMajorVersion
        if ($null -eq $PMV)
        {
            throw "Cannot form object from given hashtable. Hashtable must contain a key called 'PuppetMajorVersion"
        }
        $PlatformNameCheck = $KitchenPlatform.PlatformName
        if ($null -eq $PlatformNameCheck)
        {
            $PlatformNameCheck = $OS
        }
        $this.PlatformName = $PlatformNameCheck
        $this.OSRelease = $Releases
        $this.OperatingSystem = [TestOperatingSystems]$OS
        $this.PuppetAgentVersion = ([PuppetAgentVersion]$PA).version
    }
}