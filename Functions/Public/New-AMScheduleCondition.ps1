function New-AMScheduleCondition {    
    <#
        .SYNOPSIS
            Creates a new AutoMate Enterprise schedule condition.

        .DESCRIPTION
            New-AMScheduleCondition creates a new schedule condition.

        .PARAMETER Name
            The name of the new object.

        .PARAMETER ScheduleType
            Set the schedule to use a Custom interval.

        .PARAMETER NextLaunchDate
            The next time the schedule will execute

        .PARAMETER Frequency
            How frequently the schedule should execute the specified interval. For example: every 1 day, every 2 days, etc.

        .PARAMETER Day
            The day(s) of the week to execute the schedule on.

        .PARAMETER End
            The last date the schedule will execute.

        .PARAMETER Measure
            When using the -MonthInterval option, use this parameter to specify regular days, work days, or a specific weekday (i.e. Monday, Tuesday, etc.).

        .PARAMETER Month
            The month(s) to execute.

        .PARAMETER MonthInterval
            The frequency to execute when using a "Specific day(s) of the month" schedule type.

        .PARAMETER OnTaskLate
            The action to take when the task is late.

        .PARAMETER Reschedule
            Specify how the schedule should be rescheduled.

        .PARAMETER Notes
            The new notes to set on the object.

        .PARAMETER CompletionState
            The completion state (staging level) to set on the object.

        .PARAMETER Folder
            The folder to place the object in.

        .PARAMETER Connection
            The server to create the object on.

        .EXAMPLE
            # Create a new schedule to run every day at 8AM
            New-AMScheduleCondition -Name "Daily at 8AM" -DayInterval -NextLaunchDate (Get-Date "8:00AM")

        .EXAMPLE
            # Create a new schedule to run every other month on the third Wednesday at 9PM
            New-AMScheduleCondition -Name "Third Wednesday" -MonthInterval -Measure Wednesday -DayOfMonth third -Frequency 2 -NextLaunchDate (Get-Date "9:00PM")

        .NOTES
            Author(s):     : David Seibel
            Contributor(s) :
            Date Created   : 07/26/2018
            Date Modified  : 08/08/2018

        .LINK
            https://github.com/davidseibel/AutoMatePS
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="Low")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [ValidateNotNullOrEmpty()]
        [AMScheduleType]$ScheduleType,

        [ValidateNotNullOrEmpty()]
        [DateTime]$NextLaunchDate = (Get-Date),

        [ValidateSet(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,"first","second","third","fourth","last")]
        $Frequency = 1,

        [DayOfWeek[]]$Day,

        [DateTime]$End,

        [ValidateNotNullOrEmpty()]
        [AMScheduleMeasure]$Measure = [AMScheduleMeasure]::Day,

        [ValidateSet("January","February","March","April","May","June","July","August","September","October","November","December")]
        [string[]]$Month,

        [ValidateNotNullOrEmpty()]
        [int]$MonthInterval,

        [ValidateNotNullOrEmpty()]
        [AMOnTaskLateRescheduleOption]$OnTaskLate = [AMOnTaskLateRescheduleOption]::RunImmediately,

        [ValidateNotNullOrEmpty()]
        [AMRescheduleOption]$Reschedule = [AMRescheduleOption]::RelativeToOriginalTime,

        [string]$Notes = "",

        [ValidateNotNullOrEmpty()]
        [AMCompletionState]$CompletionState = [AMCompletionState]::Production,

        [ValidateScript({$_.Type -eq "Folder"})]
        $Folder,

        $Connection
    )

    if ($PSBoundParameters.ContainsKey("Connection")) {
        $Connection = Get-AMConnection -Connection $Connection
    } else {
        $Connection = Get-AMConnection
    }
    if (($Connection | Measure-Object).Count -gt 1) {
        throw "Multiple AutoMate Servers are connected, please specify which server to create the new schedule condition on!"
    }

    $user = Get-AMUser -Connection $Connection | Where-Object {$_.Name -ieq $Connection.Credential.UserName}
    if (-not $Folder) {
        # Place the task in the users task folder
        $Folder = $user | Get-AMFolder -Type CONDITIONS
    }

    switch ($Connection.Version.Major) {
        10      { $newObject = [AMScheduleTriggerv10]::new($Name, $Folder, $Connection.Alias) }
        11      { $newObject = [AMScheduleTriggerv11]::new($Name, $Folder, $Connection.Alias) }
        default { throw "Unsupported server major version: $_!" }
    }
    $newObject.CompletionState = $CompletionState
    $newObject.CreatedBy       = $user.ID
    $newObject.Notes           = $Notes
    $newObject.ScheduleType    = $ScheduleType
    $newObject.Frequency       = $Frequency
    $newObject.OnTaskLate      = $OnTaskLate
    $newObject.Reschedule      = $Reschedule
    $newObject.Measure         = $Measure
    if ($PSBoundParameters.ContainsKey("Day") -and ($Day | Measure-Object).Count -gt 0) {
        $newObject.Day = ($Day -join ",").ToLower() -split ","
    }
    if ($PSBoundParameters.ContainsKey("NextLaunchDate")) {
        $newObject.NextLaunchDate = Get-Date $NextLaunchDate -Format $AMScheduleDateFormat
    }
    if ($PSBoundParameters.ContainsKey("End")) {
        $newObject.End = Get-Date $End -Format $AMScheduleDateFormat
    }
    if ($ScheduleType -eq [AMScheduleType]::MonthInterval) {
        $newObject.MonthInterval = $MonthInterval
    }
    if (($PSBoundParameters.ContainsKey("Month")) -and ($Month.Count -gt 0)) {
        $newObject.Month += $Month.ToLower()
    }
    $newObject | New-AMObject -Connection $Connection
    Get-AMCondition -ID $newObject.ID -Connection $Connection
}