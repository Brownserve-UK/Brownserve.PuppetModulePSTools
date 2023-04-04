<#
.SYNOPSIS
    Builds module layer hiera from a template
#>
function Build-ModuleHieraFromTemplate
{
    [CmdletBinding()]
    param
    (
        # The path to where the hiera configuration will be stored (relative to the modules root directory)
        [Parameter(Mandatory = $false)]
        [string]
        $HieraFilePath = 'hiera.yaml',

        # The path to where templates are stored
        [Parameter(Mandatory = $false)]
        [string]
        $TemplatePath = (Join-Path $Script:PuppetTemplateDirectory 'hiera'),

        # The template to be used for this file
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $Template = 'hiera.yaml'
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
    }
    
    process
    {
        # Currently there's no customisation to be done on hiera files so just get and return them as is.
        try
        {
            $Template = Get-Content (Join-Path $TemplatePath $Template) -ErrorAction 'Stop' -Raw
        }
        catch
        {
            throw "Failed to get template '$Template'.`n$($_.Exception.Message)"
        }
        $Return = @{ FilePath = $HieraFilePath; Content = $Template }
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