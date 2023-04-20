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

enum PuppetModuleType
{
    private
    public
}

enum TestOSKernel
{
    linux
    windows
}

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