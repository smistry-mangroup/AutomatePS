function Remove-AMWorkflowVariable {
    <#
        .SYNOPSIS
            Removes a shared variable from an AutoMate Enterprise workflow

        .DESCRIPTION
            Remove-AMWorkflowVariable can remove shared variables from a workflow object.

        .PARAMETER InputObject
            The object to remove the variable from.

        .PARAMETER Name
            The name of the variable to remove.

        .INPUTS
            The following AutoMate object types can be modified by this function:
            Workflow
            WorkflowVariable

        .OUTPUTS
            None

        .EXAMPLE
            # Remove variable 'emailAddress' from workflow 'Some Workflow'
            Get-AMWorkflow "Some Workflow" | Remove-AMWorkflowVariable -Name "emailAddress"

        .NOTES
            Author(s):     : David Seibel
            Contributor(s) :
            Date Created   : 07/26/2018
            Date Modified  : 08/08/2018

        .LINK
            https://github.com/davidseibel/AutoMatePS
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject,

        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    PROCESS {
        foreach ($obj in $InputObject) {
            $shouldUpdate = $false
            switch ($obj.Type) {
                "Workflow" {
                    $update = Get-AMWorkflow -ID $obj.ID -Connection $obj.ConnectionAlias
                    if ($update.Variables.Name -contains $Name) {
                        $update.Variables = @($update.Variables | Where-Object {$_.Name -ne $Name})
                        $shouldUpdate = $true
                    }
                }
                "WorkflowVariable" {
                    $update = Get-AMWorkflow -ID $obj.ParentID -Connection $obj.ConnectionAlias
                    $update.Variables = @($update.Variables | Where-Object {$_.ID -ne $obj.ID})
                    $shouldUpdate = $true
                }
                default {
                    Write-Error -Message "Unsupported input type '$($obj.Type)' encountered!" -TargetObject $obj
                }
            }

            if ($shouldUpdate) {
                $update | Set-AMObject
            } else {
                Write-Verbose "$($obj.Type) '$($obj.Name)' does not contain a variable named '$Name'."
            }
        }
    }
}