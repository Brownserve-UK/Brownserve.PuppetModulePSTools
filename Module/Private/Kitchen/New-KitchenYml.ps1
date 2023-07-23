function New-KitchenYml
{
    [CmdletBinding()]
    param
    (

        # The provisioner options to be used
        [Parameter(Mandatory = $true)]
        [hashtable]
        $ProvisionerOptions,

        # The suite options to be used
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $SuiteOptions,

        # The platform options to be used
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $PlatformOptions,

        # The verifier options to be used, if none are specified then the defaults from New-KitchenVerifier will be used
        [Parameter(Mandatory = $false)]
        [hashtable]
        $VerifierOptions = @{}
    )
    
    begin
    {
        
    }
    
    process
    {
        try
        {
            $Provisioner = New-KitchenProvisioner @ProvisionerOptions -AsHashtable -ErrorAction 'Stop'
            $Verifier = New-KitchenVerifier @VerifierOptions -AsHashtable -ErrorAction 'Stop'
            $Suite = $SuiteOptions | ForEach-Object {
                New-KitchenSuite @_ -AsHashtable -ErrorAction 'Stop'
            }
            $Platform = $PlatformOptions | ForEach-Object {
                New-KitchenPlatform @_ -AsHashtable -ErrorAction 'Stop'
            }
            $KitchenHash = [ordered]@{
                provisioner = $Provisioner
                verifier = $Verifier
                suites = $Suite
                platforms = $Platform
            }
            $KitchenYaml = $KitchenHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to build kitchen yaml.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($KitchenYaml)
        {
            return $KitchenYaml
        }
        else
        {
            return $null
        }
    }
}