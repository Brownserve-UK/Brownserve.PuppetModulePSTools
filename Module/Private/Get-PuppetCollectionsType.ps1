function Get-PuppetCollectionsType
{
    [CmdletBinding()]
    param
    (
        # The uri to the Puppet collections repo
        [Parameter(Mandatory = $true)]
        [string]
        $CollectionsRepoURI
    )
    
    begin
    {
        $return = $null
    }
    
    process
    {
        try
        {
            $RepoInfo = $CollectionsRepoURI | ConvertFrom-URI
        }
        catch
        {
            throw "Failed to convert collections repo URI.`n$($_.Exception.Message)"
        }
        switch ($RepoInfo.Subdomain)
        {
            'apt'
            {
                $return = 'puppet_apt_collections_repo'
            }
            'yum'
            {
                $return = 'puppet_yum_collections_repo'
            }
            Default
            {
                throw "'$($RepoInfo.Subdomain)' is not supported on puppet-kitchen at present."
            }
        }
    }
    
    end
    {
        if ($null -ne $return)
        {
            return $return
        }
    }
}