function Switch-AMWorkflowItem {
    <#
        .SYNOPSIS
            Replaces items in a Automate workflow

        .DESCRIPTION
            Switch-AMWorkflowItem can replace items in a workflow object.

        .PARAMETER InputObject
            The object to replace items in.

        .PARAMETER CurrentItem
            The current item to replace.

        .PARAMETER NewItem
            The new item to replace the current item with.

        .INPUTS
            The following Automate object types can be modified by this function:
            Workflow

        .EXAMPLE
            # Replace instances of the "Copy Files" task with "Move Files" in workflow "FTP Files"
            Get-AMWorkflow "FTP Files" | Switch-AMWorkflowItem -CurrentItem (Get-AMTask "Copy Files") -NewItem (Get-AMTask "Move Files")

        .LINK
            https://github.com/AutomatePS/AutomatePS/blob/master/Docs/Switch-AMWorkflowItem.md
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="Medium")]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $CurrentItem,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $NewItem
    )

    BEGIN {
        if ($CurrentItem.ConnectionAlias -eq $NewItem.ConnectionAlias) {
            if ($CurrentItem.ID -eq $NewItem.ID) {
                throw "CurrentItem and NewItem are the same!"
            }
            if ($CurrentItem.Type -ne $NewItem.Type) {
                throw "CurrentItem and NewItem are not the same type!"
            }
        } else {
            throw "CurrentItem and NewItem are not on the same Automate server!"
        }
    }

    PROCESS {
        foreach ($obj in $InputObject) {
            if ($obj.Type -eq "Workflow") {
                if ($obj.ConnectionAlias -ne $CurrentItem.ConnectionAlias) {
                    throw "CurrentItem '$($CurrentItem.Name)' ($($CurrentItem.ConnectionAlias)) is not on the same server as '$($obj.Name)' ($($obj.ConnectionAlias))!"
                    break
                }
                if ($obj.ConnectionAlias -ne $NewItem.ConnectionAlias) {
                    throw "NewItem '$($NewItem.Name)' ($($NewItem.ConnectionAlias)) is not on the same server as '$($obj.Name)' ($($obj.ConnectionAlias))!"
                    break
                }
                $update = Get-AMWorkflow -ID $obj.ID -Connection $obj.ConnectionAlias
                $found = $false
                foreach ($item in $update.Items) {
                    if ($item.ConstructID -eq $CurrentItem.ID) {
                        $item.ConstructID = $NewItem.ID
                        $found = $true
                    }
                }
                foreach ($trigger in $update.Triggers) {
                    if ($trigger.ConstructID -eq $CurrentItem.ID) {
                        $trigger.ConstructID = $NewItem.ID
                        $found = $true
                    }
                }
                if ($found) {
                    $update | Set-AMObject
                }
            } else {
                Write-Error -Message "Unsupported input type '$($obj.Type)' encountered!" -TargetObject $obj
            }
        }
    }
}
