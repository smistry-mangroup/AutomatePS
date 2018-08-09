function Get-AMWorkflowVariable {
    <#
        .SYNOPSIS
            Gets a list of variables within a workflow.

        .DESCRIPTION
            Get-AMWorkflowVariable retrieves variables for a workflow.

        .PARAMETER InputObject
            The object to retrieve variables from.

        .PARAMETER Name
            Search on the name of the variable. Wildcards are accepted.

        .PARAMETER InitialValue
            Search on the initial value of the variable. Wildcards are accepted.

        .PARAMETER DataType
            Filter on the data type of the variable.

        .PARAMETER VariableType
            Filter on the type of variable.

        .INPUTS
            The following AutoMate object types can be queried by this function:
            Workflow

        .OUTPUTS
            WorkflowVariable

        .EXAMPLE
            # Get variables in workflow "FTP Files"
            Get-AMWorkflow "FTP Files" | Get-AMWorkflowVariable

        .NOTES
            Author(s):     : David Seibel
            Contributor(s) :
            Date Created   : 07/26/2018
            Date Modified  : 08/08/2018

        .LINK
            https://github.com/davidseibel/AutoMatePS
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        [string]$Name = "*",

        [string]$InitialValue = "*",

        [AMWorkflowVarDataType]$DataType,

        [AMWorkflowVarType]$VariableType
    )

    PROCESS {
        foreach ($obj in $InputObject) {
            Write-Verbose "Processing $($obj.Type) '$($obj.Name)'"
            if ($obj.Type -eq "Workflow") {
                foreach ($var in $obj.Variables) {
                    if ($PSBoundParameters.ContainsKey("DataType") -and $var.DataType -ne $DataType) {
                        continue
                    }
                    if ($PSBoundParameters.ContainsKey("VariableType") -and $var.VariableType -ne $VariableType) {
                        continue
                    }
                    if (($var.Name -like $Name) -and ($var.InitalValue -like $InitialValue)) {
                        $var
                    }
                }
            } else {
                Write-Error -Message "Unsupported input type '$($obj.Type)' encountered!" -TargetObject $obj
            }
        }
    }
}