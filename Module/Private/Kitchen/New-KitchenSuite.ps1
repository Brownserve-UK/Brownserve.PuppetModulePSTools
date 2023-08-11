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
        $Excludes,

        # An optional header to be displayed above the suites
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Header = @(
            "The below are the test suites kitchen will apply to test this module.",
            "The 'verifier' section is where you specify what command to run to execute the tests.",
            "By default suites are applied to all platforms, but you can use the 'includes' and 'excludes' sections to limit what platforms a suite is applied to.",
            "For example, if you have a suite that only applies to Windows, you can use the 'excludes' section to prevent it from being applied to Linux and Mac platforms.",
            "Suites are where you'll typically want to override other settings, such as the driver or provisioner settings.",
            "For more information on writing tests, see https://serverspec.org/"
        )
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
        if ($null -ne $Header)
        {
            $Header = $Header | ConvertTo-BlockComment
        }
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
        $Return = @{
            Header = $Header
            Section = $SuiteHash
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