function New-KitchenVerifier
{
    [CmdletBinding()]
    param
    (
        # The verifier to use (https://kitchen.ci/docs/verifiers/)
        [Parameter(Mandatory = $false)]
        [string]
        $Verifier = 'shell',

        # An optional header to be displayed above the suites
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Header = @(
            "The below contains verifier configuration",
            "This is where you specify what verifier to use for the tests.",
            "This can be overridden at the platform/suite level."
        )
    )
    
    begin
    {
        
    }
    
    process
    {
        if ($null -ne $Header)
        {
            $Header = $Header | ConvertTo-BlockComment
        }
        $VerifierHash = @{
            name = $Verifier
        }
        $Return = @{
            Header = $Header
            Section = $VerifierHash
        }
    }
    
    end
    {
        if ($Return)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}