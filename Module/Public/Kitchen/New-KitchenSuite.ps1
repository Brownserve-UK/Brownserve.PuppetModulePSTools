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

        # Return a hashtable instead of the converted YAML
        [Parameter(Mandatory = $false)]
        [switch]
        $AsHashtable,

        # The indentation to use for the returned YAML
        [Parameter(Mandatory = $false, DontShow)]
        [int]
        $Indentation = 2
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
        if ($AsHashtable)
        {
            $SuiteYaml = $SuiteHash
        }
        else
        {
            try
            {
                $SuiteYaml = $SuiteHash | ConvertTo-Yaml -KeepArray -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to converted suite hash to YAML.`n$($_.Exception.Message)"
            }
            # ConvertTo-Yaml is really designed to convert a complete YAML file and as such doesn't support indenting things
            if ($Indentation -gt 0)
            {
                $SuiteYamlArray = $SuiteYaml -split "`n"
                Clear-Variable 'SuiteYaml'
                $Line = 0
                $SuiteYamlArray | ForEach-Object {
                    $Line += 1
                    # Don't add a newline to the last line
                    if ($Line -eq $SuiteYamlArray.Count)
                    {
                        $SuiteYaml += ' ' * $Indentation + $_ + "`r"
                    }
                    else
                    {
                        $SuiteYaml += ' ' * $Indentation + $_ + "`n`r"
                    }
                }
            }
        }
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