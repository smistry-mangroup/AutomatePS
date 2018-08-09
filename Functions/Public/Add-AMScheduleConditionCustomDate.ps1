function Add-AMScheduleConditionCustomDate {    
    <#
        .SYNOPSIS
            Adds a custom date to an AutoMate Enterprise schedule condition using the Custom interval.

        .DESCRIPTION
            Add-AMScheduleConditionCustomDate adds a custom date to an AutoMate Enterprise schedule condition using the Custom interval.

        .PARAMETER InputObject
            The schedule condition object to add the custom date to.

        .PARAMETER CustomLaunchDates
            The dates to add to the schedule.

        .INPUTS
            The following AutoMate object types can be modified by this function:
            Condition

        .OUTPUTS
            None

        .EXAMPLE
            # Add a custom run time of 1 hour from now to schedule "On Specified Dates"
            Get-AMCondition "On Specified Dates" | Add-AMScheduleConditionCustomDate -CustomLaunchDates (Get-Date).AddHours(1)

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

        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [DateTime[]]$CustomLaunchDates
    )

    PROCESS {
        foreach ($obj in $InputObject) {
            if (($obj.Type -eq "Condition") -and ($obj.TriggerType -eq [AMTriggerType]::Schedule) -and ($obj.ScheduleType -eq [AMScheduleType]::Custom)) {
                $update = Get-AMCondition -ID $obj.ID -Connection $obj.ConnectionAlias
                $update.Day += $CustomLaunchDates | ForEach-Object { Get-Date $_ -Format $AMScheduleDateFormat }
                $update | Set-AMObject
            } else {
                Write-Error -Message "Unsupported input type '$($obj.Type)' and trigger type '$($obj.TriggerType)' encountered!" -TargetObject $obj
            }
        }
    }
}