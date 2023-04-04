<#
.SYNOPSIS
    Creates a module manifest file from a given template
.DESCRIPTION
    Creates a module manifest file from a given template by replacing placeholder text with the desired values
.EXAMPLE
    Build-PuppetModuleManifestFromTemplate
    By default this will create an init.pp and params.pp class
#>
function Build-PuppetModuleManifestFromTemplate
{
    [CmdletBinding()]
    param
    (
        # The name of the module that is being created
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $ModuleName,

        # The description of the module
        [Parameter(Mandatory = $true, Position = 1)]
        # Max ling length 140, minus the bumph at the beginning 
        [ValidateLength(1, 129)]
        [string]
        $ManifestSummary,

        # The path to where the manifest will be stored relative to the module directory, defaults to be the same name as
        # the template used
        [Parameter(Mandatory = $false)]
        [string]
        $ManifestPath = (Join-Path 'manifests' $Template),

        # The path to where templates are stored
        [Parameter(Mandatory = $false)]
        [string]
        $TemplatePath = (Join-Path $Script:PuppetTemplateDirectory 'manifests'),

        # The template to be used for this module
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $Template = 'init_no_params.pp'
    )
    
    begin
    {
        try
        {
            Get-Item $TemplatePath -ErrorAction 'Stop' | Out-Null
        }
        catch
        {
            throw "Cannot find TemplatePath $TemplatePath.`n$($_.Exception.Message)"
        }

        # Ensure the module name is always lower-case
        $ModuleName = $ModuleName.ToLower()
    }
    
    process
    {

        try
        {
            $TemplateContent = Get-Content (Join-Path $TemplatePath $Template) -ErrorAction 'Stop' -Raw
        }
        catch
        {
            throw "Failed to load template '$Template'.`n$($_.Exception.Message)"
        }
        # Replace any placeholders with real values
        $TemplateContent = $TemplateContent -replace '<MODULE_NAME>', $ModuleName
        $TemplateContent = $TemplateContent -replace '<MANIFEST_DESCRIPTION>', $ManifestSummary
        # Return a hash with the manifest name and the content
        $Return = @{ FilePath = $ManifestPath; Content = $TemplateContent }

    }
    
    end
    {
        if ($Return)
        {
            Return [BuiltTemplate]$Return
        }
        else
        {
            Return $null
        }
    }
}