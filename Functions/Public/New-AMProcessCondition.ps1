function New-AMProcessCondition {
    <#
        .SYNOPSIS
            Creates a new AutoMate Enterprise process condition.

        .DESCRIPTION
            New-AMProcessCondition creates a new process condition.

        .PARAMETER Name
            The name of the new object.

        .PARAMETER ProcessName
            The name of the process.

        .PARAMETER Action
            The state of the process to trigger on.

        .PARAMETER TriggerOnce
            Only trigger the first time the process is started or stopped.

        .PARAMETER Started
            Only trigger when the process was running prior to the condition and is then stopped.

        .PARAMETER Wait
            Wait for the condition, or evaluate immediately.

        .PARAMETER Timeout
            If wait is specified, the amount of time before the condition times out.

        .PARAMETER TimeoutUnit
            The unit for Timeout (Seconds by default).

        .PARAMETER TriggerAfter
            The number of times the condition should occur before the trigger fires.

        .PARAMETER Notes
            The new notes to set on the object.

        .PARAMETER CompletionState
            The completion state (staging level) to set on the object.

        .PARAMETER Folder
            The folder to place the object in.

        .PARAMETER Connection
            The server to create the object on.

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

        [Parameter(Mandatory = $true)]
        [string]$ProcessName,
        [AMProcessTriggerState]$Action = [AMProcessTriggerState]::StoppedResponding,
        [switch]$TriggerOnce = $false,
        [switch]$Started = $false,

        [switch]$Wait = $true,
        [int]$Timeout = 0,
        [AMTimeMeasure]$TimeoutUnit = [AMTimeMeasure]::Seconds,
        [int]$TriggerAfter = 1,

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
        throw "Multiple AutoMate Servers are connected, please specify which server to create the new process condition on!"
    }

    $user = Get-AMUser -Connection $Connection | Where-Object {$_.Name -ieq $Connection.Credential.UserName}
    if (-not $Folder) {
        # Place the task in the users condition folder
        $Folder = $user | Get-AMFolder -Type CONDITIONS
    }

    switch ($Connection.Version.Major) {
        10      { $newObject = [AMProcessTriggerv10]::new($Name, $Folder, $Connection.Alias) }
        11      { $newObject = [AMProcessTriggerv11]::new($Name, $Folder, $Connection.Alias) }
        default { throw "Unsupported server major version: $_!" }
    }
    $newObject.CompletionState = $CompletionState
    $newObject.CreatedBy       = $user.ID
    $newObject.Notes           = $Notes
    $newObject.Wait            = $Wait.ToBool()
    if ($newObject.Wait) {
        $newObject.Timeout      = $Timeout
        $newObject.TimeoutUnit  = $TimeoutUnit
        $newObject.TriggerAfter = $TriggerAfter
    }
    $newObject.Action          = $Action
    $newObject.ProcessName     = $ProcessName
    if ($Action -in ([AMProcessTriggerState]::Started,[AMProcessTriggerState]::Ended)) {
        $newObject.TriggerOnce = $TriggerOnce.ToBool()
    }
    if ($Action -eq [AMProcessTriggerState]::Ended) {
        $newObject.Started = $Started.ToBool()
    }
    $newObject | New-AMObject -Connection $Connection
    Get-AMCondition -ID $newObject.ID -Connection $Connection
}