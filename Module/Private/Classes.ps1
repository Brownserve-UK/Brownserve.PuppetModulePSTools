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

# This helps us to validate any test providers that we use
enum TestProvider
{
    kitchen_vagrant
}

# This ensures we can easily check what type of module we're creating
enum PuppetModuleType
{
    private
    public
}

# Standardise what type of kernel we are testing against
enum TestOSKernel
{
    linux
    windows
}

# Supported kitchen drivers
enum KitchenDriver
{
    vagrant
}

class HieraHierarchy
{
    [string] $Name
    [string[]] $Paths

    HieraPath([hashtable]$HieraPath)
    {
        $LocalName = $HieraPath.Name
        $LocalPaths = $HieraPath.Paths
        if (!$LocalName)
        {
            throw "Cannot form object from given hashtable. Hashtable must contain a key called 'Name'"
        }
        $This.Name = $LocalName
        if (!$LocalPaths)
        {
            throw "Cannot form object from given hashtable. Hashtable must contain a key called 'Paths'"
        }
        $This.Paths = $LocalPaths
    }
}

class BSPuppetModuleConfigurationReleaseDetails
{
    [string]$PuppetAgentURL
    [string]$ReleaseName
    [string]$ReleaseVersion
    [string]$VagrantBoxURL
    [string]$DockerImage

    # Constructor for converting a hashtable, this should be all we need when importing from JSON
    BSPuppetModuleConfigurationReleaseDetails([hashtable]$Hashtable)
    {
        if (!$Hashtable.PuppetAgentURL)
        {
            throw "Hashtable does not contain the key 'PuppetAgentURL'"
        }
        if (!$Hashtable.ReleaseName)
        {
            throw "Hashtable does not contain the key 'ReleaseName'"
        }
        if (!$Hashtable.ReleaseVersion)
        {
            throw "Hashtable does not contain the key 'ReleaseVersion'"
        }
        if (!$Hashtable.VagrantBoxURL -and !$Hashtable.DockerImage)
        {
            throw "Hashtable must contain one of 'VagrantBoxURL' or 'DockerImage'"
        }
        $This.PuppetAgentURL = $Hashtable.PuppetAgentURL
        $This.ReleaseName = $Hashtable.ReleaseName
        $this.ReleaseVersion = $Hashtable.ReleaseVersion
        if ($Hashtable.DockerImage)
        {
            $this.DockerImage = $Hashtable.DockerImage
        }
        if ($Hashtable.VagrantBoxURL)
        {
            $this.VagrantBoxURL = $Hashtable.VagrantBoxURL
        }
    }

}

class BSPuppetModuleConfigurationRelease
{
    [string]$Name
    [BSPuppetModuleConfigurationReleaseDetails]$Settings

    BSPuppetModuleConfigurationRelease([hashtable]$Hashtable)
    {
        if (!$Hashtable.ReleaseName)
        {
            throw "Hashtable must contain the key 'ReleaseName'"
        }
        $this.Name = $Hashtable.ReleaseName
        $this.Settings = $Hashtable.ReleaseSettings 
    }
}

<#
    This class ensures that our configuration is in the format we expect it to be in
#>
class BSPuppetModuleConfiguration
{
    [string]$OSFamily
    [string]$Kernel
    [BSPuppetModuleConfigurationRelease[]]$Releases

    BSPuppetModuleConfiguration([hashtable]$Hashtable)
    {
        if (!$Hashtable.OSFamily)
        {
            Write-Warning "Hashtable must contain the key 'OSFamily'"
        }
        if (!$Hashtable.Kernel)
        {
            throw "Hashtable must contain the key 'Kernel'"
        }
        if (!$Hashtable.Releases)
        {
            throw "Hashtable must contain the key 'Releases'"
        }
        $this.OSFamily = 'testData_Remove'
        $this.Kernel = $Hashtable.Kernel
        $this.Releases = $Hashtable.Releases.GetEnumerator() | ForEach-Object {
            @{
                ReleaseName = $_.Name
                ReleaseSettings = $_.Value
            }
        }
    }
}