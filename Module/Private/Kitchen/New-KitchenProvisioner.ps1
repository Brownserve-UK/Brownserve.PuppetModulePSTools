function New-KitchenProvisioner
{
    [CmdletBinding()]
    param
    (
        # The name of the main manifest to run
        [Parameter(Mandatory = $true)]
        [string]
        $ManifestName,

        # The name of the provisioner
        [Parameter(Mandatory = $false)]
        [string]
        $ProvisionerName = 'puppet_apply',

        # The path to where the Puppet manifests live (relative to .kitchen.yml)
        [Parameter(Mandatory = $false)]
        [string]
        $ManifestPath = 'spec/manifests',

        # The path to any external modules that should be loaded (relative to .kitchen.yml)
        [Parameter(Mandatory = $false)]
        [string]
        $ExternalModulesPath = '../../ext-modules:../../modules',

        # The path to the test hiera that should be used
        [Parameter(Mandatory = $false)]
        [string]
        $HieraDataPath = 'spec/hieradata',

        # The path to the hiera config to be used (relative to .kitchen.yml)
        [Parameter(Mandatory = $false)]
        [string]
        $HieraConfigPath = '../../hiera.tests.yaml',

        # Whether or not to enable hiera deep merge
        [Parameter(Mandatory = $false)]
        [bool]
        $EnableHieraDeepMerge = $false,

        # Any custom facts that should be injected into the apply
        [Parameter(Mandatory = $false)]
        [hashtable]
        $CustomFacts = @{'ci_cd' = $true },

        # Any paths that should be ignored
        [Parameter(Mandatory = $false)]
        [string[]]
        $IgnoredPathsFromRoot = @('.kitchen'),

        # Require chef for busser
        [Parameter(Mandatory = $false)]
        [bool]
        $RequireChefForBusser = $false,

        # Whether or not to enable librarian Puppet
        [Parameter(Mandatory = $false)]
        [bool]
        $ResolveWithLibrarianPuppet = $false,

        # Whether or not to require the puppet repo
        [Parameter(Mandatory = $false)]
        [bool]
        $RequirePuppetRepo = $false,

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [bool]
        $VerifyHostKey = $false,

        # The maximum number of retries before declaring idempotency failure
        [Parameter(Mandatory = $false)]
        [int]
        $MaxRetries = 2,

        # The time (in seconds) to wait between retries
        [Parameter(Mandatory = $false)]
        [int]
        $WaitForRetry = 10,

        # The exit codes to retry on
        [Parameter(Mandatory = $false)]
        [int[]]
        $RetryOnExitCode = @(2, 4, 6),

        # Whether or not to enable detailed exit codes in Puppet
        [Parameter(Mandatory = $false)]
        [bool]
        $DetailedExitCodes = $true,

        # Whether or not to enable verbose mode in Puppet
        [Parameter(Mandatory = $false)]
        [bool]
        $PuppetVerbose = $true,

        # Whether or not to enable Puppet's debug mode
        [Parameter(Mandatory = $false)]
        [bool]
        $PuppetDebug = $false,

        # Whether or not to show diffs for changes during the run
        [Parameter(Mandatory = $false)]
        [bool]
        $PuppetShowDiff = $false,

        # Whether or not to perform no-op's
        [Parameter(Mandatory = $false)]
        [bool]
        $PuppetNoOp = $false,

        # Allows returning as a hashtable instead for reasons
        [Parameter(Mandatory = $false)]
        [switch]
        $AsHashtable
    )
    
    begin
    {
        
    }
    
    process
    {
        if ($ManifestName -notmatch '\.pp$')
        {
            $ManifestName = $ManifestName + '.pp'
        }
        # Form a hash from all the options that must be set
        $ProvisionerHash = [ordered]@{
            name                          = $ProvisionerName
            manifests_path                = $ManifestPath
            manifest                      = $ManifestName
            hiera_data_path               = $HieraDataPath
            hiera_deep_merge              = $EnableHieraDeepMerge
            require_chef_for_busser       = $RequireChefForBusser
            resolve_with_librarian_puppet = $ResolveWithLibrarianPuppet
            require_puppet_repo           = $RequirePuppetRepo
            verify_host_key               = $VerifyHostKey
            puppet_detailed_exitcodes     = $DetailedExitCodes
            max_retries                   = $MaxRetries
            wait_for_retry                = $WaitForRetry
            retry_on_exit_code            = $RetryOnExitCode
            puppet_verbose                = $PuppetVerbose
            puppet_debug                  = $PuppetDebug
            puppet_show_diff              = $PuppetShowDiff
            puppet_noop                   = $PuppetNoOp
        }
        # Add anything the user may have defined
        if ($HieraConfigPath)
        {
            $ProvisionerHash.Add('hiera_config_path', $HieraConfigPath)
        }
        if ($ExternalModulesPath)
        {
            $ProvisionerHash.Add('modules_path', $ExternalModulesPath)
        }
        if ($IgnoredPathsFromRoot)
        {
            $ProvisionerHash.Add('ignored_paths_from_root', $IgnoredPathsFromRoot)
        }
        if ($CustomFacts)
        {
            $ProvisionerHash.Add('custom_facts', $CustomFacts)
        }

        if ($AsHashtable)
        {
            $ProvisionerYaml = $ProvisionerHash
        }
        else
        {
            try
            {
                $ProvisionerYaml = $ProvisionerHash | Invoke-ConvertToYaml -ErrorAction 'Stop' 
            }
            catch
            {
                throw "Failed to create provisioner YAML.`n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        if ($ProvisionerYaml)
        {
            return $ProvisionerYaml
        }
        else
        {
            return $null
        }
    }
}