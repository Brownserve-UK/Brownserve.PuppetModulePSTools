function New-PuppetClass
{
    [CmdletBinding()]
    param
    (
        # The name of the class
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        # The module that this class belongs to
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,

        # An optional description of the class
        [Parameter(Mandatory = $false)]
        [string[]]
        $Description,

        # Optional content to include in the class
        [Parameter(Mandatory = $false)]
        [string[]]
        $Content,

        # If this is a private class or not
        [Parameter(Mandatory = $false)]
        [switch]
        $Private
    )
    
    begin
    {
        $Name = $Name.ToLower()
        $ModuleName = $ModuleName.ToLower()
        if ($Name -notlike "*$ModuleName*")
        {
            $Name = "$ModuleName::$Name"
        }
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
        if ($Private)
        {
            $ClassContent += "# @api private`n"
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