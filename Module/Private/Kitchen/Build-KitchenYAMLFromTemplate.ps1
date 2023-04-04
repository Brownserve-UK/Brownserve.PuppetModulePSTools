<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
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
function Build-KitchenYAMLFromTemplate
{
    [CmdletBinding()]
    param
    (
        # The test suite block to inject into the template
        [Parameter(Mandatory = $true)]
        [string]
        $SuiteBlock,

        # The platform block to inject into the template
        [Parameter(Mandatory = $true)]
        [string]
        $PlatformBlock,

        # The name of the manifest file that is used for Kitchen tests
        [Parameter(Mandatory = $true)]
        [string]
        $KitchenManifestFileName,

        # The filename of the Kitchen YAML to be created
        [Parameter(Mandatory = $false)]
        [string]
        $KitchenYAMLFileName = '.kitchen.yml',

        # The path of the Kitchen YAML to be created (relative to the Puppet module)
        [Parameter(Mandatory = $false)]
        [string]
        $KitchenYAMLFilePath = $KitchenYAMLFileName,

        # The name of the template to use
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateFile = '.kitchen.yml',

        # The directory that houses the template files
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateDirectory = (Join-Path $global:PuppetTemplateDirectory 'kitchen')
    )
    
    begin
    {
        # Start by ensuring the template exists and we can import it
        try
        {
            $KitchenTemplate = Get-Content (Join-Path $TemplateDirectory $TemplateFile) -Raw -ErrorAction 'Stop'
        }
        catch
        {
            throw "Unable to import template '$TemplateFile'.`n$($_.Exception.Message)"
        }
        $Return = $null
    }
    
    process
    {
        $KitchenTemplate = $KitchenTemplate -replace '### <MANIFEST_NAME> ###', $KitchenManifestFileName
        $KitchenTemplate = $KitchenTemplate -replace '### <PLATFORMS_DEFINITION> ###', $PlatformBlock
        $KitchenTemplate = $KitchenTemplate -replace '### <SUITES_DEFINITION> ###', $SuiteBlock
        $Return = @{ 
            Content = $KitchenTemplate
            FilePath = $KitchenYAMLFilePath
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