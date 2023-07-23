function New-KitchenDriver
{
    [CmdletBinding()]
    param
    (
        # The name of the driver to be used
        [Parameter(Mandatory = $true)]
        [KitchenDriver]
        $Driver,

        # Any additional parameters to be used (can vary by driver)
        [Parameter(Mandatory = $false)]
        [hashtable]
        $AdditionalParameters
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
                $DriverHash = $DriverHash + $AdditionalParameters
            }
            catch
            {
                throw "Failed to merge driver hashtable objects.`n$($_.Exception.Message)"
            }
        }
        $DriverYaml = $DriverHash
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