# SupportedOSConfiguration
Some cmdlets feature the `-SupportedOSConfiguration` parameter, this parameter is designed to allow the user to pass in a list of operating systems (and their required details) that should be supported by the Puppet module being created/updated.  
If no configuration is passed to this parameter then the defaults from [`SupportedOS_Defaults.jsonc`](../Module/Private/SupportedOS_Defaults.jsonc) are used.  
Similarly the user can specify their own JSON file by using the hidden `-ConfigurationFile` parameter which may be easier than passing a hashtable to `-SupportedOSConfiguration`.  
For more information on using a custom configuration file please see [the example configuration file](ExampleSupportedOSConfig.jsonc) which is fully documented.