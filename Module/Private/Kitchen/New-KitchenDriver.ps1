function New-KitchenDriver
{
    [CmdletBinding()]
    param
    (
        # The name of the driver to be used
        [Parameter(Mandatory = $false)]
        [KitchenDriver]
        $Driver = 'vagrant',

        # Any additional parameters to be used (can vary by driver)
        [Parameter(Mandatory = $false)]
        [hashtable]
        $AdditionalParameters,

        # If set returns the object as a Hashtable instead of as YAML
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
        
    }
    
    process
    {
        $DriverHash = @{
            name = $Driver
        }
        if ($AdditionalParameters)
        {
            try
            {
                $DriverHash + $AdditionalParameters
            }
            catch
            {
                throw "Failed to merge driver hashtable objects.`n$($_.Exception.Message)"
            }
        }
        if ($AsHashtable)
        {
            $DriverYaml = $DriverHash
        }
        else
        {
            try
            {
                $DriverYaml = $DriverHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to convert driver object into YAML.`n$($_.Exception.Message)"
            }
            if ($Indentation -gt 0)
            {
                $DriverYAMLArray = $DriverYaml -split "`n"
                Clear-Variable 'DriverYaml'
                $Line = 0
                $DriverYAMLArray | ForEach-Object {
                    $Line += 1
                    if ($Line -eq $DriverYAMLArray.Count)
                    {
                        $DriverYaml += ' ' * $Indentation + $_ + "`r"
                    }
                    else
                    {
                        $DriverYaml += ' ' * $Indentation + $_ + "`n`r"
                    }
                }
            }
        }
    }
    
    end
    {
        if ($DriverYaml)
        {
            return $DriverYaml
        }
        else
        {
            return $null
        }
    }
}