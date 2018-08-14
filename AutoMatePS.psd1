#
# Module manifest for module 'PSGet_AutoMatePS'
#
# Generated by: David Seibel
#
# Generated on: 8/14/2018
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'AutoMatePS'

# Version number of this module.
ModuleVersion = '2.0.1'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '410dd814-d087-4645-a62e-0388a22798c0'

# Author of this module
Author = 'David Seibel'

# Company or vendor of this module
CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = '(c) 2018 David Seibel. All rights reserved.'

# Description of the functionality provided by this module
Description = 'AutoMatePS provides PowerShell integration with HelpSystems AutoMate Enterprise'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = 'types\custom.ps1', 'types\enums.ps1', 'types\v10.ps1', 'types\v11.ps1'

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = 'AutoMatePS.Format.ps1xml'

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Add-AMAgentGroupMember', 'Add-AMConstant', 
               'Add-AMEmailConditionFilter', 'Add-AMScheduleConditionCustomDate', 
               'Add-AMScheduleConditionHoliday', 'Add-AMSnmpConditionCredential', 
               'Add-AMUserGroupMember', 'Add-AMWindowConditionControl', 
               'Add-AMWorkflowItem', 'Add-AMWorkflowLink', 'Add-AMWorkflowVariable', 
               'Connect-AMServer', 'Copy-AMCondition', 'Copy-AMProcess', 'Copy-AMTask', 
               'Copy-AMWorkflow', 'Disable-AMObject', 'Disconnect-AMServer', 
               'Enable-AMObject', 'Find-AMObject', 'Get-AMAgent', 'Get-AMAgentGroup', 
               'Get-AMAuditEvent', 'Get-AMCalendar', 'Get-AMCondition', 
               'Get-AMConnection', 'Get-AMConnectionStoreItem', 
               'Get-AMConsoleOutput', 'Get-AMExecutionEvent', 'Get-AMFolder', 
               'Get-AMFolderRoot', 'Get-AMInstance', 'Get-AMMetric', 'Get-AMObject', 
               'Get-AMObjectProperty', 'Get-AMPermission', 'Get-AMProcess', 
               'Get-AMServer', 'Get-AMSession', 'Get-AMSystemAgent', 
               'Get-AMSystemPermission', 'Get-AMTask', 'Get-AMUser', 'Get-AMUserGroup', 
               'Get-AMWorkflow', 'Get-AMWorkflowLink', 'Get-AMWorkflowVariable', 
               'Invoke-AMRestMethod', 'Lock-AMObject', 'Move-AMObject', 'New-AMAgent', 
               'New-AMAgentGroup', 'New-AMConnectionStoreItem', 
               'New-AMDatabaseCondition', 'New-AMEmailCondition', 
               'New-AMEventLogCondition', 'New-AMFileSystemCondition', 
               'New-AMFolder', 'New-AMIdleCondition', 'New-AMKeyboardCondition', 
               'New-AMLogonCondition', 'New-AMObject', 'New-AMPerformanceCondition', 
               'New-AMPermission', 'New-AMProcess', 'New-AMProcessCondition', 
               'New-AMScheduleCondition', 'New-AMServiceCondition', 
               'New-AMSharePointCondition', 'New-AMSnmpCondition', 
               'New-AMSystemPermission', 'New-AMTask', 'New-AMUser', 'New-AMUserGroup', 
               'New-AMWindowCondition', 'New-AMWmiCondition', 'New-AMWorkflow', 
               'Open-AMWorkflowDesigner', 'Remove-AMAgentGroupMember', 
               'Remove-AMConnectionStoreItem', 'Remove-AMConstant', 
               'Remove-AMEmailConditionFilter', 'Remove-AMObject', 
               'Remove-AMPermission', 'Remove-AMScheduleConditionHoliday', 
               'Remove-AMSnmpConditionCredential', 'Remove-AMSystemPermission', 
               'Remove-AMUserGroupMember', 'Remove-AMWindowConditionControl', 
               'Remove-AMWorkflowLink', 'Remove-AMWorkflowVariable', 
               'Rename-AMObject', 'Resume-AMInstance', 'Resume-AMWorkflow', 
               'Set-AMAgent', 'Set-AMAgentGroup', 'Set-AMAgentProperty', 
               'Set-AMCondition', 'Set-AMDatabaseCondition', 'Set-AMEmailCondition', 
               'Set-AMEmailConditionFilter', 'Set-AMEventLogCondition', 
               'Set-AMFileSystemCondition', 'Set-AMFolder', 'Set-AMIdleCondition', 
               'Set-AMKeyboardCondition', 'Set-AMLogonCondition', 'Set-AMObject', 
               'Set-AMPerformanceCondition', 'Set-AMProcess', 
               'Set-AMProcessCondition', 'Set-AMScheduleCondition', 
               'Set-AMServiceCondition', 'Set-AMSharePointCondition', 
               'Set-AMSnmpCondition', 'Set-AMSnmpConditionCredential', 'Set-AMTask', 
               'Set-AMTaskProperty', 'Set-AMUser', 'Set-AMUserGroup', 
               'Set-AMWindowCondition', 'Set-AMWindowConditionControl', 
               'Set-AMWmiCondition', 'Set-AMWorkflow', 'Set-AMWorkflowItem', 
               'Set-AMWorkflowProperty', 'Set-AMWorkflowVariable', 'Start-AMProcess', 
               'Start-AMTask', 'Start-AMWorkflow', 'Stop-AMInstance', 
               'Suspend-AMInstance', 'Switch-AMWorkflowItem', 'Unlock-AMObject', 
               'Wait-AMAgent', 'Wait-AMInstance'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/davidseibel/AutoMatePS'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/davidseibel/AutoMatePS'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

