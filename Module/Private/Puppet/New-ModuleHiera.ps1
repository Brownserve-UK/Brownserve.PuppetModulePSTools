function New-ModuleHiera
{
    [CmdletBinding()]
    param
    (
        # The paths to use
        [Parameter(Mandatory = $true)]
        [HieraHierarchy[]]
        $HieraHierarchy,

        # The name of the data directory
        [Parameter(Mandatory = $false)]
        [string]
        $DataDirectory = 'data',

        # The hash to be used
        [Parameter(Mandatory = $false)]
        [string]
        $DataHashType = 'yaml_data',

        # The version of hiera to use
        [Parameter(Mandatory = $false)]
        [int]
        $HieraVersion = 5
    )
    
    begin
    {
        
    }
    
    process
    {
        $HieraHash = [ordered]@{
            version   = $HieraVersion
            defaults  = @{
                datadir   = $DataDirectory
                data_hash = $DataHashType
            }
            hierarchy = @()
        }
        $HieraHierarchy | ForEach-Object {
            $HieraHash.hierarchy += [ordered]@{
                name  = $_.Name
                paths = $_.Paths
            }
        }
        try
        {
            $HieraYaml = $HieraHash | Invoke-ConvertToYaml -ErrorAction 'stop'
            if (!$HieraYaml)
            {
                Write-Error "No yaml returned."
            }
        }
        catch
        {
            throw "Failed to convert hash to yaml.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($HieraYaml)
        {
            return $HieraYaml
        }
    }
}