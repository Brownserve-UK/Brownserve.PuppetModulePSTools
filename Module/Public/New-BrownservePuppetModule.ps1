function New-BrownservePuppetModule
{
    [CmdletBinding()]
    param
    (
        # The name of the module
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,

        # The path to where the module should be created
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # An optional description for this module
        [Parameter(Mandatory = $false)]
        [string[]]
        $Description,

        # Whether to include a params class
        [Parameter(Mandatory = $false)]
        [bool]
        $IncludeParams = $true,

        # Forces the creation of the module even if it exists
        [Parameter(Mandatory = $false)]
        [switch]
        $Force
    )
    
    begin
    {
        
    }
    
    process
    {
        $ModuleName = $ModuleName.ToLower() # In the future might be good to filter this to allowed Puppet characters
        # Ensure the module doesn't already exists
        $ModuleAbsolutePath = Join-Path $Path $ModuleName
        if ($Force -ne $true)
        {
            if (Test-Path $ModuleAbsolutePath)
            {
                throw "Module already exists at '$ModuleAbsolutePath'."
            }
        }
        $ManifestDirectory = Join-Path $ModuleAbsolutePath 'manifests'
        $InitParams = @{
            Name       = $ModuleName
            ModuleName = $ModuleName
        }
        if ($Description)
        {
            $InitParams.Add('Description', $Description)
        } 
        if ($IncludeParams)
        {
            $InitParams.Add('Content', "include $ModuleName::params")
            $ParamsParams = @{
                Name        = 'params'
                ModuleName  = $ModuleName
                Description = 'Private class for managing module parameters'
                Private     = $true
            }
        }

        try
        {
            $InitContent = New-PuppetClass @InitParams -ErrorAction 'stop'
        }
        catch
        {
            throw "Failed to generate init content.`n$($_.Exception.Message)"
        }
        if ($ParamsParams)
        {
            try
            {
                $ParamsContent = New-PuppetClass @ParamsParams -ErrorAction 'stop'
            }
            catch
            {
                throw "Failed to generate params content.`n$($_.Exception.Message)"
            }
        }

        # Now that everything has been done we can create the module
        try
        {
            New-Item $ModuleAbsolutePath -ItemType 'directory' -ErrorAction 'stop' -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create '$ModuleAbsolutePath'.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item $ManifestDirectory -ItemType 'directory' -ErrorAction 'stop' -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create '$ManifestDirectory'.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item (Join-Path $ManifestDirectory 'init.pp') -Value $InitContent -ErrorAction 'stop' -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create init.pp.`n$($_.Exception.Message)"
        }

        if ($ParamsParams)
        {
            try
            {
                New-Item (Join-Path $ManifestDirectory 'params.pp') -Value $ParamsContent -ErrorAction 'stop' -Force:$Force | Out-Null
    
            }
            catch
            {
                throw "Failed to create params.pp`n$($_.Exception.Message)"
            }        
        }
    }
    
    end
    {
        
    }
}