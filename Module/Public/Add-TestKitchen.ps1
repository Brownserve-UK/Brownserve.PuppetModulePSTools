function Add-TestKitchen
{
    [CmdletBinding()]
    param
    (
        # The path to the module
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $ModulePath,

        # The type of module to be created, standalone (forge) or environment (nested modules directory within a repo)
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [PuppetModuleType]
        $ModuleType,

        # The name of the module
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleName = (Split-Path $ModulePath -LeafBase),

        # Whether or not to use templates
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]
        $UseTemplates = $false,

        # The path relative to the module where the templates are stored
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $TemplateRelativePath,

        # Forces overwrite of any files that already exist
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $Force,

        # Special config file for test hiera config
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $TestHieraConfigFile = (Join-Path $Script:ModuleConfigDirectory 'test_hiera_config.json'),

        # Special config file to use for kitchen config
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $KitchenConfigFile = (Join-Path $Script:ModuleConfigDirectory 'kitchen_config.json'),

        # Load our special OS mapping config file
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $OSInfoConfigFile = (Join-Path $Script:ModuleConfigDirectory 'os_info.json'),

        # Special config file for storing acceptance test config
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $AcceptanceTestConfigFile = (Join-Path $Script:ModuleConfigDirectory 'acceptance_config.json')
    )
    
    begin
    {
        
    }
    
    process
    {
        Assert-Directory $ModulePath -ErrorAction 'Stop'
        if ($UseTemplates -eq $true)
        {
            if (!$TemplateRelativePath)
            {
                throw 'TemplateRelativePath must be set when UseTemplates is true'
            }
            
            <# 
                Grab all the templates and then combine them into a single hashtable.
                We have some logic later on that will scrub the Kitchen configuration for certain things and
                perform some checks/transformation
            #>
            try
            {
                # It's important to start the YML file with the correct header otherwise it throws formatters off
                $KitchenContent = "---`n"
                $KitchenTemplatePath = (Join-Path $ModulePath $TemplateRelativePath)
                Write-Debug "KitchenTemplatePath: $KitchenTemplatePath"
                Assert-Directory $KitchenTemplatePath
                # Load all the children that are either yml or yaml files, we do not scan recursively as the user may have separate directories for different templates
                $KitchenTemplates = Get-ChildItem `
                    -Path  $KitchenTemplatePath `
                    -ErrorAction 'Stop' | 
                        Where-Object { ($_.Name -like '*.yml') -or ($_.Name -like '*.yaml') }
                if (!$KitchenTemplates)
                {
                    throw "No templates found in the specified path '$KitchenTemplatePath'"
                }
                # Create a Ruby file open command for each template (Kitchen processes as Ruby)
                $KitchenTemplates | ForEach-Object {
                    $KitchenContent += "<%= File.open(`"$TemplateRelativePath/$($_.Name)`").read %>`n"
                }
                # Get the content of each file and load it in as YML
                $KitchenTemplateYML = $KitchenTemplates | 
                    ForEach-Object { Get-Content -Path $_.FullName -Raw } | 
                        Out-String
                Write-Debug "KitchenTemplateYML: $KitchenTemplateYML"
                # Convert to a PowerShell object for use later on.
                $KitchenYMLObject = Invoke-ConvertFromYaml $KitchenTemplateYML -ErrorAction 'Stop'
                $KitchenYML = @{
                    Path    = '.kitchen.yml'
                    Content = $KitchenContent
                }
            }
            catch
            {
                throw "Failed to load templates. `n$($_.Exception.Message)"
            }
        }
        else
        {
            $KitchenParams = @{}
            if ($KitchenConfigFile)
            {
                $KitchenParams.Add('KitchenConfigFile', $KitchenConfigFile)
            }
            if ($OSInfoConfigFile)
            {
                $KitchenParams.Add('OSInfoConfigFile', $OSInfoConfigFile)
            }
            $KitchenYML = New-KitchenYml @KitchenParams
            # We store the object separately due to the way that the template logic above works
            $KitchenYMLObject = $KitchenYML.Object
        }

        # N.B paths are relative to the $ModulePath
        $DirectoriesToCreate = @()
        $FilesToCreate = @(
            @{
                Path    = '.kitchen.yml'
                Content = $KitchenYML.Content
            }
        )
        <#
            We'll read the output of the kitchen.yml file to ensure we have a single source of truth for the data.
        #>
        # Work out where the test Puppet manifests need to end up
        $TestManifestDirectory = $KitchenYMLObject.provisioner.manifests_path
        if (!$TestManifestDirectory)
        {
            throw "Provisioner property 'manifests_path' has not been set."
        }
        Write-Debug "TestManifestDirectory: $TestManifestDirectory"
        $DirectoriesToCreate += $TestManifestDirectory

        # Work out the base directory by splitting the path
        $DirectoriesToCreate += Split-Path $TestManifestDirectory

        # Work out where the hiera stuff should end up
        $TestHieraDirectory = $KitchenYMLObject.provisioner.hiera_data_path
        if (!$TestHieraDirectory)
        {
            throw "Provisioner property 'hiera_data_path' has not been set."
        }
        Write-Debug "TestHieraDirectory: $TestHieraDirectory"
        $DirectoriesToCreate += $TestHieraDirectory

        # The parent might be different so extract that too
        $DirectoriesToCreate += Split-Path $TestHieraDirectory

        # Create a default Hiera file for kitchen to use
        try
        {
            $NewNodeHieraParams = @{}
            if ($TestHieraConfigFile)
            {
                $NewNodeHieraParams.Add('ConfigFile', $TestHieraConfigFile)
                $NewNodeHieraParams.Add('ConfigFileKey', $ModuleType)
            }
            $TestHieraFile = New-NodeHiera @NewNodeHieraParams -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to create Hiera file. `n$($_.Exception.Message)"
        }

        # Create a default Hiera file
        $FilesToCreate += @(
            @{
                Path    = (Join-Path $TestHieraDirectory 'common.yaml')
                Content = $TestHieraFile
            }
        )

        # There should be a default manifest for us to use, regardless of whether the user has chosen to override it in a suite/platform or not
        # It'll just be a single file with an include statement for the module we're testing
        $DefaultManifest = $KitchenYMLObject.provisioner.manifest
        if (!$DefaultManifest)
        {
            throw "Provisioner property 'manifest' has not been set."
        }
        $FilesToCreate += @{
            Path    = (Join-Path $TestManifestDirectory $DefaultManifest)
            Content = "include $ModuleName"
        }

        if ($KitchenYMLObject.provisioner.hiera_config_path)
        {
            # TODO: do a test to make sure we can find it?
        }

        if ($KitchenYMLObject.suites)
        {
            # May have more than one suite...
            $KitchenYMLObject.suites | ForEach-Object {
                <#
                    We attempt to grab the name of the acceptance test file the user is calling for the suite, this is so we can create it for them.
                    To do that we take the name of the file (e.g spec/acceptance/my_test.rb -> my_test) and then pass it into New-AcceptanceTest which has some logic
                    to template acceptance tests 
                #>
                if ($_.verifier.command -match '(?<test_path>\S*\/.*?\.\S*)')
                {
                    # Grab the path to the acceptance test
                    $TestFilePath = $Matches.test_path
                    try
                    {
                        if (!$TestFilePath)
                        {
                            throw 'Failed to extract TestFilePath'
                        }
                        $AcceptanceParams = @{}
                        # Extract the name of the file from the path
                        $TestFileName = Split-Path $TestFilePath -LeafBase
                        if (!$TestFileName)
                        {
                            throw 'Unable to determine TestFileName'
                        }

                        <#
                            If we've got a config file then try and form an acceptance test from that.
                            If not then don't pass it through to the New-AcceptanceTest cmdlet which will likely result
                            in a blank acceptance test being returned (fine for our needs)
                        #>
                        if ($AcceptanceTestConfigFile)
                        {
                            $AcceptanceParams.Add('ConfigFileKey', $TestFileName)
                            $AcceptanceParams.Add('ConfigFile', $AcceptanceTestConfigFile)
                        }
                        # Use ModuleType as the key to work out helper file path. We may want to make this end-user configurable in the future
                        if ($null -ne $ModuleType)
                        {
                            $AcceptanceParams.Add('HelperFilePathKey', "$ModuleType")
                        }
                        
                        $TestFileContent = New-AcceptanceTest @AcceptanceParams
                    }
                    catch
                    {
                        throw "Failed to generate spec test file. `n$($_.Exception.Message)"
                    }

                    # We'll need to check and create the acceptance test directory too
                    $DirectoriesToCreate += Split-Path $TestFilePath

                    # We'll create the acceptance tests
                    $FilesToCreate += @{
                        Path    = $TestFilePath
                        Content = $TestFileContent
                    }
                }
                else
                {
                    throw "Couldn't determine acceptance test from verifier command."
                }
            }
        }
        else
        {
            <# 
                What do we want to do when there are no suites? Create some default ones?
                If we do, do we use the same suites as defined in kitchen_config? I think so...
                We could have a -Suites param where a user can define their own or a key in the config file?
                We could param it on this and have a config file to read default param data?
            #>
        }

        # Providing all the above is fine we can start creating files on disk
        # First check all the directories don't exist (some directories may be shared hence separate check/create)
        $DirectoriesToCreate | ForEach-Object {
            $DirectoryToCheck = Join-Path $ModulePath $_
            Write-Verbose "Checking if directory '$DirectoryToCheck' exists."
            if ((Test-Path $DirectoryToCheck) -and (!$Force))
            {
                throw "Directory '$DirectoryToCheck' already exists."
            }
        }

        $DirectoriesToCreate | ForEach-Object {
            $DirectoryToCreate = Join-Path $ModulePath $_
            if (!(Test-Path $DirectoryToCreate))
            {
                try
                {
                    New-Item `
                        -Path $DirectoryToCreate `
                        -ItemType Directory `
                        -ErrorAction 'Stop' `
                        -Force:$Force
                }
                catch
                {
                    throw "Failed to create directory '$DirectoryToCreate'. `n$($_.Exception.Message)"
                }
            }
        }
        $FilesToCreate | ForEach-Object {
            try
            {
                $FileToCreate = (Join-Path $ModulePath $_.Path)
                New-Item `
                    -Path  $FileToCreate `
                    -Value $_.Content `
                    -ErrorAction 'Stop' `
                    -Force:$Force
            }
            catch
            {
                throw "Failed to create file '$FileToCreate'. `n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        
    }
}