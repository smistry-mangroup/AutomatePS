function Remove-AMSnmpConditionCredential {
    <#
        .SYNOPSIS
            Removes a credential from an AutoMate Enterprise SNMP condition.

        .DESCRIPTION
            Remove-AMSnmpConditionCredential removes a credential from an AutoMate Enterprise SNMP condition.

        .PARAMETER InputObject
            The SNMP condition object to remove the credential from.

        .PARAMETER ID
            The ID of the credential.

        .INPUTS
            The following AutoMate object types can be modified by this function:
            Condition

        .OUTPUTS
            None

        .EXAMPLE
            Get-AMCondition "snmp" | Remove-AMSnmpConditionCredential -ID "{5ccaab49-012a-48db-b186-696061e20a2c}"

        .NOTES
            Author(s):     : David Seibel
            Contributor(s) :
            Date Created   : 07/26/2018
            Date Modified  : 08/08/2018

        .LINK
            https://github.com/davidseibel/AutoMatePS
    #>
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject,

        [Parameter(Mandatory = $true)]
        $ID
    )

    PROCESS {
        foreach ($obj in $InputObject) {
            if (($obj.Type -eq "Condition") -and ($obj.TriggerType -eq [AMTriggerType]::SNMPTrap)) {
                $updateObject = Get-AMCondition -ID $obj.ID -Connection $obj.ConnectionAlias
                if ((($updateObject.Credentials | Where-Object {$_.ID -ne $ID}) | Measure-Object).Count -gt 0) {
                    $updateObject.Credentials = @($updateObject.Credentials | Where-Object {$_.ID -ne $ID})
                } else {
                    $updateObject.Credentials = @()
                }
                $updateObject | Set-AMObject
            } else {
                Write-Error -Message "Unsupported input type '$($obj.Type)' and trigger type '$($obj.TriggerType)' encountered!" -TargetObject $obj
            }
        }
    }
}