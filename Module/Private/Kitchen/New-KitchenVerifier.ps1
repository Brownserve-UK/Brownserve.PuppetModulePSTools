function New-KitchenVerifier
{
    [CmdletBinding()]
    param
    (
        # The verifier to use (https://kitchen.ci/docs/verifiers/)
        [Parameter(Mandatory = $false)]
        [string]
        $Verifier = 'shell',

        # Returns a hashtable instead of YAML
        [Parameter(Mandatory = $false)]
        [switch]
        $AsHashtable
    )
    
    begin
    {
        
    }
    
    process
    {
        $VerifierHash = @{
            name = $Verifier
        }
        if ($AsHashtable)
        {
            $VerifierYAML = $VerifierHash
        }
        else
        {
            try
            {
                $VerifierYAML = $VerifierHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to create verifier into YAML.`n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        if ($VerifierYAML)
        {
            return $VerifierYAML
        }
        else
        {
            return $null
        }
    }
}