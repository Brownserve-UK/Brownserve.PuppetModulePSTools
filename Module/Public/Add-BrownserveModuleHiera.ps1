function Add-BrownserveModuleHiera
{
    [CmdletBinding()]
    param
    (
        # The path to the module to add the hiera too
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Path','PSPath')]
        [string]
        $ModulePath,

        # The paths to use
        [Parameter(Mandatory = $false)]
        [string[]]
        $HieraPaths = @('common.yaml')
    )
    
    begin
    {
        
    }
    
    process
    {
        $DataDirectory = 'data'
        $DataDirectoryPath = Join-Path $ModulePath $DataDirectory
        $HieraContent = "---`n# Hiera module layer configuration (https://puppet.com/docs/puppet/6/hiera_config_yaml_5.html)`n"
        try
        {
            $ModuleCheck = Get-Item $ModulePath -ErrorAction 'stop' | Where-Object { $_.PSIsContainer -eq $true }
            if (!$ModuleCheck)
            {
                Write-Error "$ModulePath is not a valid directory."
            }
        }
        catch
        {
            throw "$($_.Exception.Message)"
        }
        $HieraParams = @{
            DataDirectory  = $DataDirectory
            HieraHierarchy = @{
                Name  = 'Module layer default data'
                Paths = $HieraPaths
            }
        }
        try
        {
            $HieraYaml = New-ModuleHiera @HieraParams -ErrorAction 'Stop'
            $HieraContent += $HieraYaml
        }
        catch
        {
            throw "Failed to generate module hiera.`n$($_.Exception.Message)"
        }
        try
        {
            $HieraYamlPath = Join-Path $ModulePath 'hiera.yaml'
            New-Item $HieraYamlPath -Value $HieraContent -ErrorAction 'Stop' | Out-Null
        }
        catch
        {
            throw "Failed to created $HieraYamlPath.`n$($_.Exception.Message)"
        }
        try
        {
            New-Item $DataDirectoryPath -ItemType Directory -ErrorAction 'stop' | Out-Null
        }
        catch
        {
            throw "Failed to create '$DataDirectoryPath'.`n$($_.Exception.Message)"
        }
        try
        {
            $HieraPaths | ForEach-Object {
                # Only create files that are not interpolated from facts or other values as we can't guess these names easily
                if ($_ -notmatch ('^\%'))
                {
                    New-Item (Join-Path $DataDirectoryPath $_) -Value "---`n" -ErrorAction 'stop' | Out-Null
                }
            }
        }
        catch
        {
            throw "Failed to create data file.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}