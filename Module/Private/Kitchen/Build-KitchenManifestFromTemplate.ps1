<#
.SYNOPSIS
    Creates a Puppet manifest for Kitchen to use from a given template file.
.DESCRIPTION
    This cmdlet will create a Puppet manifest for Kitchen to use in test definitions from a given template file.
    As it stands we typically only have one manifest for all tests, but in the future if we decide to create more then
    this cmdlet should be flexible enough to do so.
.EXAMPLE
    Build-KitchenManifestFromTemplate -ModuleName Foo
    This will create a file named 'kitchen.pp' which would contain one line reading 'include foo.pp'
#>


function Build-KitchenManifestFromTemplate
{
    [CmdletBinding()]
    param
    (
        # The name of the Puppet module that contains these tests
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,

        # The name of manifest that should be created (defaults to the module name)
        [Parameter(Mandatory = $false)]
        [string]
        $ManifestFileName = 'kitchen.pp',

        # The path to where the manifest file will live (relative to the Puppet module)
        [Parameter(Mandatory = $false)]
        [string]
        $ManifestFilePath = (Join-Path 'spec' 'manifests' $ManifestFileName),
        
        # The name of the template to use
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateFile = 'default.pp',

        # The directory that houses the template files
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateDirectory = (Join-Path $global:PuppetTemplateDirectory 'kitchen' 'manifests')
    )
    
    begin
    {
        # Start by ensuring the template exists and we can import it
        try
        {
            $ManifestTemplate = Get-Content (Join-Path $TemplateDirectory $TemplateFile) -Raw -ErrorAction 'Stop'
        }
        catch
        {
            throw "Unable to import template '$TemplateFile'.`n$($_.Exception.Message)"
        }
        $Return = $null
    }
    
    process
    {
        $ManifestTemplate = $ManifestTemplate -replace '<MODULE_NAME>', $ModuleName
        $Return = @{
            Content  = $ManifestTemplate
            FilePath = $ManifestFilePath
        }
    }
    
    end
    {
        try
        {
            return [BuiltTemplate]$Return
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
}