<#
.SYNOPSIS
    This cmdlet will create a ruby spec file to be used for Kitchen tests.
.DESCRIPTION
    This cmdlet will create a ruby spec file to be used for Kitchen tests.
    If a helper is specified then spec file will be adjusted to ensure it is loaded.
.EXAMPLE
    Build-KitchenAcceptanceTestFromTemplate
    
    This will create a blank spec test file called 'default_tests_spec.rb'
.EXAMPLE
    Build-KitchenAcceptanceTestFromTemplate -Helper 'linux' -SpecFileName 'linux_tests_spec.rb'
    
    This will create a blank spec test file called 'linux_tests_spec.rb' which would contain the line
    'require_relative '../../../../spec_linuxhelper''
#>
function Build-KitchenAcceptanceTestFromTemplate
{
    [CmdletBinding()]
    param
    (
        # Many of our tests require a helper file to work correctly
        [Parameter(Mandatory = $false)]
        [KitchenSuiteHelpers]
        $Helper,

        # The name of the spec file to be created
        [Parameter(Mandatory = $false)]
        [string]
        $SpecFileName = 'default_tests_spec.rb',

        # The path to where the acceptance test will live (relative to the module)
        [Parameter(Mandatory = $false)]
        [string]
        $SpecFilePath = (Join-Path 'spec' 'acceptance' $SpecFileName),

        # The name of the template to use
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateFile = 'default.rb',
        
        # The directory that houses the template files
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateDirectory = (Join-Path $global:PuppetTemplateDirectory 'kitchen' 'acceptance')
    )
    
    begin
    {
        # Start by ensuring the template exists and we can import it
        try
        {
            $AcceptanceTemplate = Get-Content (Join-Path $TemplateDirectory $TemplateFile) -Raw -ErrorAction 'Stop'
        }
        catch
        {
            throw "Unable to import template '$TemplateFile'.`n$($_.Exception.Message)"
        }
        $Return = $null
    }
    
    process
    {
        if ($null -ne $Helper)
        {
            $HelperString = "`nrequire_relative '../../../../spec_$($Helper)helper'`n"
        }
        if ($HelperString)
        {
            $AcceptanceTemplate = $AcceptanceTemplate -replace '## <HELPER> ##', $HelperString
        }
        else
        {
            $AcceptanceTemplate = $AcceptanceTemplate -replace '## <HELPER> ##', ''
        }
        $Return = @{
            Content  = $AcceptanceTemplate
            FilePath = $SpecFilePath
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