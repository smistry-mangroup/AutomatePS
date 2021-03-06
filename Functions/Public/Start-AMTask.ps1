function Start-AMTask {
    <#
        .SYNOPSIS
            Starts Automate tasks.

        .DESCRIPTION
            Start-AMTask starts tasks.

        .PARAMETER InputObject
            The tasks to start.

        .PARAMETER Agent
            The agent to run the task on.

        .PARAMETER AgentGroup
            The agent group to run the task on.

        .PARAMETER Variables
            The variables to pass into a workflow or task at runtime.

        .INPUTS
            Tasks can be supplied on the pipeline to this function.

        .EXAMPLE
            # Starts task "My Task" on agent "agent01"
            Get-AMTask "My Task" | Start-AMTask -Agent "agent01"

        .EXAMPLE
            # Starts task "My Task" on agent "agent01" with variables var1 and var
            Get-AMTask "My Task" | Start-AMTask -Agent "agent01" -Variables @{var1 = 123, var2 = 456}

        .LINK
            https://github.com/AutomatePS/AutomatePS/blob/master/Docs/Start-AMTask.md
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="Medium")]
    [OutputType([AMInstancev10],[AMInstancev11])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        [Parameter(ParameterSetName = "Agent")]
        [ValidateNotNullOrEmpty()]
        $Agent,

        [Parameter(ParameterSetName = "AgentGroup")]
        [ValidateNotNullOrEmpty()]
        $AgentGroup,

        [Hashtable]$Variables
    )

    PROCESS {
        foreach ($obj in $InputObject) {
            if ($obj.Type -eq "Task") {
                if ($PSBoundParameters.ContainsKey("Variables")) {
                    if (-not (Test-AMFeatureSupport -Connection $obj.ConnectionAlias -Feature ApiRuntimeVariables -Action Throw)) {
                        break
                    }
                }
                $connection = Get-AMConnection -ConnectionAlias $obj.ConnectionAlias
                switch($PSCmdlet.ParameterSetName) {
                    "Agent" {
                        if ($Agent -is [string]) {
                            $name = $Agent
                            # Can't assign agent directly because of ValidateNotNullOrEmpty on parameter
                            $tempAgent = Get-AMAgent -Name $name -Connection $obj.ConnectionAlias
                            if (($tempAgent | Measure-Object).Count -eq 1) {
                                $Agent = $tempAgent
                            } else {
                                throw "Agent '$name' not found!"
                            }
                        }
                        if ($Agent.Type -eq "Agent") {
                            if ($Agent.AgentType -eq "TaskAgent") {
                                if ($Agent.ConnectionAlias -eq $obj.ConnectionAlias) {
                                    Write-Verbose "Running task $($obj.Name) on agent $($Agent.Name)."
                                    $runUri = Format-AMUri -Path "tasks/$($obj.ID)/run" -Variables $Variables -Parameters "agent_id=$($Agent.ID)"
                                } else {
                                    throw "Task '$($obj.Name)' and agent '$($Agent.Name)' are not on the same server!"
                                }
                            } else {
                                throw "Agent $($Agent.Name) is not a task agent!"
                            }
                        } else {
                            throw "Unsupported agent type '$($Agent.Type)' encountered!"
                        }
                    }
                    "AgentGroup" {
                        if ($AgentGroup -is [string]) {
                            $name = $AgentGroup
                            # Can't assign agent directly because of ValidateNotNullOrEmpty on parameter
                            $tempAgentGroup = Get-AMAgentGroup -Name $name -Connection $obj.ConnectionAlias
                            if (($tempAgentGroup | Measure-Object).Count -eq 1) {
                                $AgentGroup = $tempAgentGroup
                            } else {
                                throw "Agent group '$name' not found!"
                            }
                        }
                        if ($AgentGroup.Type -eq "AgentGroup") {
                            if ($AgentGroup.ConnectionAlias -eq $obj.ConnectionAlias) {
                                Write-Verbose "Running task $($obj.Name) on agent group $($AgentGroup.Name)."
                                $runUri = Format-AMUri -Path "tasks/$($obj.ID)/run" -Variables $Variables -Parameters "agent_group_id=$($AgentGroup.ID)"
                            } else {
                                throw "Task '$($obj.Name)' and agent group '$($AgentGroup.Name)' are not on the same server!"
                            }
                        } else {
                            throw "Unsupported agent group type '$($AgentGroup.Type)' encountered!"
                        }
                    }
                }
                if ($PSCmdlet.ShouldProcess($connection.Name, "Starting task: $(Join-Path -Path $obj.Path -ChildPath $obj.Name)")) {
                    $instanceID = Invoke-AMRestMethod -Resource $runUri -RestMethod Post -Connection $obj.ConnectionAlias
                    Start-Sleep -Seconds 1   # The instance can't be retrieved right away, have to pause briefly
                    $listUri = Format-AMUri -Path "instances/list" -FilterSet @{Property = "ID"; Operator = "="; Value = $instanceID}
                    Invoke-AMRestMethod -Resource $listUri -RestMethod Get -Connection $obj.ConnectionAlias
                }
            } else {
                Write-Error -Message "Unsupported input type '$($obj.Type)' encountered!" -TargetObject $obj
            }
        }
    }
}