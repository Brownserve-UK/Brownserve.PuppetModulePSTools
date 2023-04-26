function Find-VagrantBox
{
    [CmdletBinding()]
    param
    (
        # The organisation/owner of the box
        [Parameter(Mandatory = $true)]
        [string]
        $BoxOwner,

        # The name of the operating system to be searched for
        [Parameter(Mandatory = $true)]
        [string]
        $OSName,

        # An additional search string to be used to correctly narrow down the box
        [Parameter(Mandatory = $false)]
        [string]
        $AdditionalSearchString
    )
    
    begin
    {
        try
        {
            Get-Command 'vagrant' -ErrorAction 'Stop'
        }
        catch
        {
            throw 'vagrant command not found on system.'
        }
    }
    
    process
    {
        $SearchString = "$BoxOwner/$OSName"
        if ($AdditionalSearchString)
        {
            $SearchString += $AdditionalSearchString
        }
        try
        {
            $Boxes = Invoke-NativeCommand `
                -FilePath 'vagrant' `
                -ArgumentList @('cloud','search',$SearchString,'--json') `
                -SuppressOutput `
                -PassThru `
                -ErrorAction 'Stop'
            if (!$Boxes)
            {
                Write-Error "No boxes found matching '$SearchString'"
            }
            else
            {
                $BoxesJSON = $Boxes | ConvertFrom-Json
                # In the future it might be nice to iterate over these and ask the user if the box matches what they were expecting.
                # but maybe that is better done up a logic level in whatever calls this cmdlet?
                $Box = $BoxesJSON[0].name
            }
        }
        catch
        {
            throw "Failed to retrieve matching vagrant box.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($Box)
        {
            return $Box
        }
    }
}