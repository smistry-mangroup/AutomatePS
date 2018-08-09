function Add-AMEmailConditionFilter {
    <#
        .SYNOPSIS
            Adds a filter to an AutoMate Enterprise Email condition.

        .DESCRIPTION
            Add-AMEmailConditionFilter adds a filter to an AutoMate Enterprise Email condition.

        .PARAMETER InputObject
            The Email condition object to add the filter to.

        .PARAMETER FieldName
            The field name to filter on.

        .PARAMETER Operator
            The filter operator.

        .PARAMETER FieldValue
            The value for the filter.

        .INPUTS
            The following AutoMate object types can be modified by this function:
            Condition

        .OUTPUTS
            None

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

        [ValidateSet("From","To","CC","Subject","Body","Date","Time","AttachmentName","AttachmentExtension","AttachmentSize","AttachmentCount")]
        [string]$FieldName,
        [ValidateSet("Equal","NotEqual","Less","LessOrEqual","Greater","GreaterOrEqual","Contains","NotContains")]
        [string]$Operator,
        [string]$FieldValue
    )

    PROCESS {
        :objectloop foreach ($obj in $InputObject) {
            if (($obj.Type -eq "Condition") -and ($obj.TriggerType -eq [AMTriggerType]::Email)) {
                $updateObject = Get-AMCondition -ID $obj.ID -Connection $obj.ConnectionAlias
                foreach ($ef in $updateObject.EmailFilters) {
                    if ($ef.FieldName -eq $FieldName -and $ef.FieldValue -eq $FieldValue -and $ef.Operator -eq $Operator) {
                        Write-Verbose "$($obj.Type) '$($obj.Name)' already contains a filter with the specified values."
                        continue objectloop
                    }
                }
                switch ((Get-AMConnection $obj.ConnectionAlias).Version.Major) {
                    10      { $emailFilter = [AMEmailFilterv10]::new() }
                    11      { $emailFilter = [AMEmailFilterv11]::new() }
                    default { throw "Unsupported server major version: $_!" }
                }
                $emailFilter.FieldName = $FieldName
                $emailFilter.FieldValue = $FieldValue
                $emailFilter.Operator = $Operator
                $emailFilter.EmailTriggerID = $updateObject.ID
                $updateObject.EmailFilters += $emailFilter
                $updateObject | Set-AMObject
            } else {
                Write-Error -Message "Unsupported input type '$($obj.Type)' and trigger type '$($obj.TriggerType)' encountered!" -TargetObject $obj
            }
        }
    }
}