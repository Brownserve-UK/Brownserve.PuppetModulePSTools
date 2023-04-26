function Get-PuppetAptCollectionsRepo
{
    [CmdletBinding()]
    param
    (
        # The version name of the OS
        [Parameter(Mandatory = $true)]
        [string]
        $ReleaseName,

        # The major version of Puppet to get
        [Parameter(Mandatory = $true)]
        [string]
        $PuppetMajorVersion,

        # The URI to check
        [Parameter(Mandatory = $false)]
        [string]
        $PuppetAptCollectionURI = 'https://apt.puppet.com/'
    )
    
    begin
    {

    }
    
    process
    {
        try
        {
            $Result = (Invoke-WebRequest $PuppetAptCollectionURI -ErrorAction 'Stop').Links | 
                Where-Object { $_.href -like "*release-$($ReleaseName.ToLower())*" } | 
                    Select-Object -ExpandProperty href
            if (!$Result)
            {
                throw "No apt repositories for release name '$ReleaseName' can be found at $PuppetAptCollectionURI"
            }
            else
            {
                $SearchString = "^puppet$PuppetMajorVersion-release-$ReleaseName.deb"
                $Repo = $Result | Where-Object { $_.ToLower() -match $SearchString }
            }
            if (!$Repo)
            {
                throw "No repositories matching '$SearchString' can be found at $PuppetAptCollectionURI.`nThe following repos are available for this release:`n$($Result | Out-String)"
            }
            if ($Repo.count -gt 1)
            {
                throw "Too many results found matching '$SearchString'.`n$Repo"
            }
            else
            {
                $Return = $PuppetAptCollectionURI + $Repo
            }
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    
    end
    {
        if ($Return)
        {
            return $Return
        }
    }
}