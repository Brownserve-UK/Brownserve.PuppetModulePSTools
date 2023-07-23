function New-KitchenSuite
{
    [CmdletBinding()]
    param
    (
        # The name of the suite
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $SuiteName,

        # The name of the spec file associated with this suite
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $SpecFileName,

        # The path (relative to .kitchen.yml) to where the suite manifest will live
        [Parameter(Mandatory = $false, Position = 2)]
        [string]
        $SpecFileRelativePath = 'spec/acceptance',

        # The execution command to run for this suite
        [Parameter(Mandatory = $false, Position = 3)]
        [string]
        $SpecExecCommand = 'rspec -c -f d -I spec',

        # An optional list of platforms that this suite should include
        [Parameter(Mandatory = $false)]
        [array]
        $Includes,

        # An optional list of platforms that this suite should exclude
        [Parameter(Mandatory = $false)]
        [array]
        $Excludes
    )
    
    begin
    {
        if ($SpecFileRelativePath -notmatch '\/$')
        {
            $SpecFileRelativePath += '/'
        }
    }
    
    process
    {
        if ($SpecFileName -notmatch '\.rb$')
        {
            $SpecFileName = $SpecFileName + '.rb'
        }

        $SuiteHash = @(
            [ordered]@{
                name     = $SuiteName
                verifier = @{
                    command = ($SpecExecCommand + ' ' + $SpecFileRelativePath + $SpecFileName)
                }
            }
        )
        if ($Includes)
        {
            $SuiteHash[0].Add('includes', $Includes)
        }
        if ($Excludes)
        {
            $SuiteHash[0].Add('excludes', $Excludes)
        }
        $SuiteYaml = $SuiteHash
    }
    end
    {
        if ($SuiteYaml)
        {
            return $SuiteYaml
        }
        else
        {
            return $null
        }
    }
}