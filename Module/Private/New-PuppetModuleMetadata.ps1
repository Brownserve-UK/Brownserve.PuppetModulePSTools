function New-PuppetModuleMetadata
{
    [CmdletBinding()]
    param
    (
        # The name of the module
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,

        # Puppet forge username
        [Parameter(Mandatory = $true)]
        [string]
        $ForgeUsername,

        # The author of the module
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleAuthor,

        # The summary of the module
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleSummary,

        # The licence to use for the module
        [Parameter(Mandatory = $true)]
        [string]
        $License,

        # The supported OSes
        [Parameter(Mandatory = $true)]
        [ordered[]]
        $SupportedOS,

        # The requirements of the module
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Requirements,

        # The source/repository associated with this module
        [Parameter(Mandatory = $false)]
        [uri]
        $Source
    )
    
    begin
    {
        
    }
    
    process
    {
        if ($ModuleName -match "^$ForgeUsername-\-")
        {
            $CompleteName = $ModuleName
        }
        else
        {
            $CompleteName = "$ForgeUsername-$ModuleName"
        }
        $Hash = [ordered]@{
            name                    = $CompleteName
            version                 = '0.1.0'
            author                  = $ModuleAuthor
            summary                 = $ModuleSummary
            license                 = $License
            source                  = "$Source"
            project_page            = "$Source"
            issues_url              = "$Source"
            operatingsystem_support = $SupportedOS
            requirements            = $Requirements
            dependencies            = @()
            tags                    = @()
        }
        try
        {
            $JSON = $Hash | ConvertTo-Json -Depth 100
        }
        catch
        {
            throw "Failed JSON conversion.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($JSON)
        {
            return $JSON
        }
    }
}