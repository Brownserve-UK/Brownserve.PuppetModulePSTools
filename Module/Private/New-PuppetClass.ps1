function New-PuppetClass
{
    [CmdletBinding()]
    param
    (
        # The name of the class
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        # An optional description of the class
        [Parameter(Mandatory = $false)]
        [string[]]
        $Description,

        # Optional content to include in the class
        [Parameter(Mandatory = $false)]
        [string[]]
        $Content
    )
    
    begin
    {
        $Name = $Name.ToLower()
    }
    
    process
    {
        if ($Description -gt 0)
        {
            $ClassContent += "# @summary`n"
            $Description | ForEach-Object {
                $ClassContent += "#   $_`n"
            }
        }
        $ClassContent += "class $Name`n"
        $ClassContent += "()`n" # Parameters currently out of scope, maybe in the future
        $ClassContent += "{`n"
        if ($Content)
        {
            $Content | ForEach-Object {
                $ClassContent += "  $_`n"
            }
        }
        $ClassContent += "}`n"
    }
    
    end
    {
        return $ClassContent
    }
}