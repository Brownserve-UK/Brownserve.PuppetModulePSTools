function New-KitchenVerifier
{
    [CmdletBinding()]
    param
    (
        # The verifier to use (https://kitchen.ci/docs/verifiers/)
        [Parameter(Mandatory = $false)]
        [string]
        $Verifier = 'shell'
    )
    
    begin
    {
        
    }
    
    process
    {
        $VerifierHash = @{
            name = $Verifier
        }

        $VerifierYAML = $VerifierHash
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