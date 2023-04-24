function New-AcceptanceTest
{
    [CmdletBinding()]
    param
    (
        # Any requirements
        [Parameter(Mandatory = $false)]
        [string[]]
        $Requirements,

        # Any local requirements
        [Parameter(Mandatory = $false)]
        [string[]]
        $RelativeRequirements
    )
    
    begin
    {
        
    }
    
    process
    {
        $Content = "# Encoding: utf-8`n`r`n"
        if ($RelativeRequirements.Count -gt 0)
        {
            $RelativeRequirements | ForEach-Object {
                $Content += "require_relative '$_'`n"
            }
            $Content += "`n"
        }
        if ($Requirements.Count -gt 0)
        {
            $Requirements | ForEach-Object {
                $Content += "require '$_'`n"
            }
            $Content += "`n"
        }
        $Content += "# Write your tests below`n"
    }
    
    end
    {
        return $Content
    }
}