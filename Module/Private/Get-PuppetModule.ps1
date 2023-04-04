<#
.SYNOPSIS
    Returns a list of Puppet modules from a given path
.DESCRIPTION
    This cmdlet will scan a given path for any Puppet modules, it does this by looking for a a particular directory structure
    and by checking for the presence of .pp files within that structure.
    Should they be found then an object is returned with the name of the module and the path to it on disk.
#>
function Get-PuppetModule
{
    [CmdletBinding()]
    param
    (
        # The path to where the modules are stored
        [Parameter(Mandatory = $true)]
        [string[]]
        $ModulePath
    )
    
    begin
    {
        $Return = @()
    }
    
    process
    {
        $ModulePath | ForEach-Object {
            try
            {
                $Children = Get-ChildItem -Path $_ -ErrorAction 'Stop' | 
                    Where-Object { $_.PSIsContainer -eq $true } |
                        # Ignore dot files which could pollute our results
                        Where-Object {$_.Name -notmatch '^\.'}
                if (!$Children)
                {
                    # If we can't find any children at all then bomb out here
                    throw "Unable to find any module at the provided path."
                }
                
                # Now we need to work out if we're dealing with a singular module or an environment with multiple modules

                # If it's a single module we should be able to find a sub-dir called 'manifests'
                $ModuleCheck = $Children | Where-Object {$_.Name -eq 'manifests'}

                # If it's an environment/collection of modules then the manifests directory will be nested below the children
                # we grabbed earlier
                $EnvironmentCheck = Get-ChildItem $Children |
                    Where-Object { $_.PSIsContainer -eq $true } |
                        Where-Object {$_.Name -eq 'manifests'} |
                        # Rule out accidentally capturing a single module that contains a spec directory...
                            Where-Object {$_.Parent.Name -ne 'spec'}

                # Only one of the above should ever be true
                if ($ModuleCheck)
                {
                    $ManifestDir = $ModuleCheck
                }
                else 
                {
                    $ManifestDir = $EnvironmentCheck
                }
                
                if (!$ManifestDir)
                {
                    throw "Unable to find 'manifests' directory at the provided path or any of its children"
                }

                # Now to ensure this is a proper module we make sure the manifest directory isn't empty
                $EmptyModuleFilter = $ManifestDir | Get-ChildItem -Filter '*.pp'
                if (!$EmptyModuleFilter)
                {
                    throw "Module at '$_' appears to be an empty module/environment"
                }

                # Now we have a sanitized list we can filter down to just the directory names
                $Return += $EmptyModuleFilter.Directory.Parent | Select-Object Name,FullName
            }
            catch
            {
                throw "Failed to get Puppet modules at '$_'.`n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        if ($Return -ne @())
        {
            # Filter out any duplicate module names
            Return $Return | Sort-Object Name -Unique
        }
        else
        {
            Return $null
        }
    }
}