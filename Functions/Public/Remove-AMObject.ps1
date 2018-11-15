function Remove-AMObject {
    <#
        .SYNOPSIS
            Removes an AutoMate Enterprise object.

        .DESCRIPTION
            Remove-AMObject receives AutoMate Enterprise object(s) on the pipeline, or via the parameter $InputObject, and deletes the object(s).

        .PARAMETER InputObject
            The object(s) to be deleted.

        .PARAMETER SkipUsageCheck
            Skips checking if object is in use.

        .INPUTS
            The following objects can be disabled by this function:
            Workflow
            Task
            Condition
            Process
            TaskAgent
            ProcessAgent
            AgentGroup
            User
            UserGroup

        .OUTPUTS
            None

        .EXAMPLE
            # Deletes agent "agent01"
            Get-AMAgent "agent01" | Remove-AMObject

        .NOTES
            Author(s):     : David Seibel
            Contributor(s) :
            Date Created   : 07/26/2018
            Date Modified  : 11/15/2018

        .LINK
            https://github.com/davidseibel/AutoMatePS
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $InputObject,

        [switch]$SkipUsageCheck = $false
    )

    BEGIN {
        $workflowCache = @{}
        $taskCache = @{}
        $processCache = @{}
        $conditionCache = @{}
        $userCache = @{}
        $userGroupCache = @{}
        $agentCache = @{}
        $agentGroupCache = @{}
    }

    PROCESS {
        foreach ($obj in $InputObject) {
            Write-Verbose "Processing $($obj.Type) '$($obj.Name)'"
            if (-not $SkipUsageCheck.ToBool()) {
                if (-not $workflowCache.ContainsKey($obj.ConnectionAlias)) {
                    Write-Verbose "Caching workflow objects for server $($obj.ConnectionAlias) for better performance"
                    $workflowCache.Add($obj.ConnectionAlias, (Get-AMWorkflow -Connection $obj.ConnectionAlias))
                }
                # Check if there are any dependencies on the object, and warn user
                switch ($obj.Type) {
                    {($_ -in @("Workflow","Task","Process","Condition"))} {
                        foreach ($workflow in $workflowCache[$obj.ConnectionAlias]) {
                            if (($workflow.Triggers.ConstructID -contains $obj.ID) -or ($workflow.Items.ConstructID -contains $obj.ID)) {
                                Write-Warning "$($obj.Type) '$($obj.Name)' is used in workflow '$($workflow.Name)'"
                            }
                        }
                    }
                    {($_ -in @("Agent","AgentGroup"))} {
                        foreach ($workflow in $workflowCache[$obj.ConnectionAlias]) {
                            if (($workflow.Triggers.AgentID -contains $obj.ID) -or ($workflow.Items.AgentID -contains $obj.ID)) {
                                Write-Warning "$($obj.Type) '$($obj.Name)' is used in workflow '$($workflow.Name)'"
                            }
                        }
                    }
                    "Folder" {
                        if (-not $taskCache.ContainsKey($obj.ConnectionAlias)) {
                            Write-Verbose "Caching task objects for server $($obj.ConnectionAlias) for better performance"
                            $taskCache.Add($obj.ConnectionAlias, (Get-AMTask -Connection $obj.ConnectionAlias))
                        }
                        if (-not $processCache.ContainsKey($obj.ConnectionAlias)) {
                            Write-Verbose "Caching process objects for server $($obj.ConnectionAlias) for better performance"
                            $processCache.Add($obj.ConnectionAlias, (Get-AMProcess -Connection $obj.ConnectionAlias))
                        }
                        if (-not $conditionCache.ContainsKey($obj.ConnectionAlias)) {
                            Write-Verbose "Caching condition objects for server $($obj.ConnectionAlias) for better performance"
                            $conditionCache.Add($obj.ConnectionAlias, (Get-AMCondition -Connection $obj.ConnectionAlias))
                        }
                        if (-not $userCache.ContainsKey($obj.ConnectionAlias)) {
                            Write-Verbose "Caching user objects for server $($obj.ConnectionAlias) for better performance"
                            $userCache.Add($obj.ConnectionAlias, (Get-AMUser -Connection $obj.ConnectionAlias))
                        }
                        if (-not $userGroupCache.ContainsKey($obj.ConnectionAlias)) {
                            Write-Verbose "Caching user group objects for server $($obj.ConnectionAlias) for better performance"
                            $userGroupCache.Add($obj.ConnectionAlias, (Get-AMUserGroup -Connection $obj.ConnectionAlias))
                        }
                        if (-not $agentCache.ContainsKey($obj.ConnectionAlias)) {
                            Write-Verbose "Caching agent objects for server $($obj.ConnectionAlias) for better performance"
                            $agentCache.Add($obj.ConnectionAlias, (Get-AMAgent -Connection $obj.ConnectionAlias))
                        }
                        if (-not $agentGroupCache.ContainsKey($obj.ConnectionAlias)) {
                            Write-Verbose "Caching agent group objects for server $($obj.ConnectionAlias) for better performance"
                            $agentGroupCache.Add($obj.ConnectionAlias, (Get-AMAgentGroup -Connection $obj.ConnectionAlias))
                        }
                        if ($obj.Path -like "\WORKFLOWS*") {
                            foreach ($workflow in $workflowCache[$obj.ConnectionAlias]) {
                                if ($workflow.ParentID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' contains workflow '$($workflow.Name)'"
                                }
                            }
                            foreach ($user in $userCache[$obj.ConnectionAlias]) {
                                if ($user.WorkflowFolderID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' is the workflow user folder for '$($user.Name)'"
                                }
                            }
                        }
                        if ($obj.Path -like "\TASKS*") {
                            foreach ($task in $taskCache[$obj.ConnectionAlias]) {
                                if ($task.ParentID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' contains task '$($task.Name)'"
                                }
                            }
                            foreach ($user in $userCache[$obj.ConnectionAlias]) {
                                if ($user.TaskFolderID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' is the task user folder for '$($user.Name)'"
                                }
                            }
                        }
                        if ($obj.Path -like "\CONDITIONS*") {
                            foreach ($condition in $conditionCache[$obj.ConnectionAlias]) {
                                if ($condition.ParentID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' contains condition '$($condition.Name)'"
                                }
                            }
                            foreach ($user in $userCache[$obj.ConnectionAlias]) {
                                if ($user.ConditionFolderID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' is the condition user folder for '$($user.Name)'"
                                }
                            }
                        }
                        if ($obj.Path -like "\PROCESSES*") {
                            foreach ($process in $processCache[$obj.ConnectionAlias]) {
                                if ($process.ParentID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' contains process '$($process.Name)'"
                                }
                            }
                            foreach ($user in $userCache[$obj.ConnectionAlias]) {
                                if ($user.ProcessFolderID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' is the process user folder for '$($user.Name)'"
                                }
                            }
                        }
                        if ($obj.Path -like "\USERS*") {
                            foreach ($user in $userCache[$obj.ConnectionAlias]) {
                                if ($user.ParentID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' contains user '$($user.Name)'"
                                }
                            }
                        }
                        if ($obj.Path -like "\USERGROUPS*") {
                            foreach ($userGroup in $userGroupCache[$obj.ConnectionAlias]) {
                                if ($userGroup.ParentID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' contains user group '$($userGroup.Name)'"
                                }
                            }
                        }
                        if ($obj.Path -like "\TASKAGENTS*") {
                            foreach ($agent in $agentCache[$obj.ConnectionAlias] | Where-Object {$_.AgentType -eq [AMAgentType]::TaskAgent}) {
                                if ($agent.ParentID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' contains agent '$($agent.Name)'"
                                }
                            }
                        }
                        if ($obj.Path -like "\PROCESSAGENTS*") {
                            foreach ($agent in $agentCache[$obj.ConnectionAlias] | Where-Object {$_.AgentType -eq [AMAgentType]::ProcessAgent}) {
                                if ($agent.ParentID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' contains agent '$($agent.Name)'"
                                }
                            }
                        }
                        if ($obj.Path -like "\AGENTGROUPS*") {
                            foreach ($agentGroup in $agentGroupCache[$obj.ConnectionAlias]) {
                                if ($agentGroup.ParentID -eq $obj.ID) {
                                    Write-Warning "Folder '$(Join-Path -Path $obj.Path -ChildPath $obj.Name)' contains user group '$($agentGroup.Name)'"
                                }
                            }
                        }
                    }
                    "User" {
                        # Do nothing
                    }
                    "UserGroup" {
                        if ($obj.UserIDs.Count -gt 0) {
                            $systemPermission = $obj | Get-AMSystemPermission
                            if ($null -ne $systemPermission) {
                                if (-not $userCache.ContainsKey($obj.ConnectionAlias)) {
                                    Write-Verbose "Caching user objects for server $($obj.ConnectionAlias) for better performance"
                                    $userCache.Add($obj.ConnectionAlias, (Get-AMTask -Connection $obj.ConnectionAlias))
                                }
                                Write-Warning "User Group '$($obj.Name)' has a system permission defined!"
                                foreach ($user in $userCache[$obj.ConnectionAlias]) {
                                    if ($user.ID -in $obj.UserIDs) {
                                        Write-Warning "User Group '$($obj.Name)' contains user '$($user.Name)'"
                                    }
                                }
                            }
                        }
                    }
                    default {
                        Write-Error -Message "Unsupported input type '$($obj.Type)' encountered!" -TargetObject $obj
                    }
                }
            }

            if ($PSCmdlet.ShouldProcess($obj.ConnectionAlias, "Removing $($obj.Type): $(Join-Path -Path $obj.Path -ChildPath $obj.Name)")) {
                Write-Verbose "Deleting object '$($obj.Name) (Type: $($obj.Type))'."
                Invoke-AMRestMethod -Resource "$([AMTypeDictionary]::($obj.Type).RestResource)/$($obj.ID)/delete" -RestMethod Post -Connection $obj.ConnectionAlias
            }
        }
    }
}

New-Alias -Name Remove-AMAgent      -Value Remove-AMObject -Scope Global
New-Alias -Name Remove-AMAgentGroup -Value Remove-AMObject -Scope Global
New-Alias -Name Remove-AMCondition  -Value Remove-AMObject -Scope Global
New-Alias -Name Remove-AMProcess    -Value Remove-AMObject -Scope Global
New-Alias -Name Remove-AMTask       -Value Remove-AMObject -Scope Global
New-Alias -Name Remove-AMUser       -Value Remove-AMObject -Scope Global
New-Alias -Name Remove-AMUserGroup  -Value Remove-AMObject -Scope Global
New-Alias -Name Remove-AMWorkflow   -Value Remove-AMObject -Scope Global