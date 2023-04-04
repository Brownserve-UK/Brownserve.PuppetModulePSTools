<#
.SYNOPSIS
    This cmdlet builds a Hiera file for Kitchen to use in tests
.DESCRIPTION
    As it stands this cmdlet supports no customisation with the expectation that any customisations are taken care of in
    the template that is used
.EXAMPLE
    Build-KitchenHieraDataFromTemplate
#>
function Build-KitchenHieraDataFromTemplate
{
    [CmdletBinding()]
    param
    (
        # The name of the hiera data file that will be created
        [Parameter(Mandatory = $false)]
        [string]
        $HieraFileName = 'common.yaml',

        # The path to where the hiera data file will live (relative to the Puppet module)
        [Parameter(Mandatory = $false)]
        [string]
        $HieraFilePath = (Join-Path 'spec' 'hieradata' $HieraFileName),

        # The name of the template to use
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateFile = 'default.yaml',

        # The directory that houses the template files
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateDirectory = (Join-Path $Script:PuppetTemplateDirectory 'kitchen' 'hieradata')
    )
    
    begin
    {
        
        $Return = $null
    }
    
    process
    {
        # Right now we only have one template and it requires no customisation
        try
        {
            $Content = Get-Content (Join-Path $TemplateDirectory $TemplateFile) -Raw -ErrorAction 'Stop'
        }
        catch
        {
            throw "Unable to load template $TemplateFile.`n$($_.Exception.Message)"
        }
        $Return = @{
            Content = $Content
            FilePath = $HieraFilePath
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