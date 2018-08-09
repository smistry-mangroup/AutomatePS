function Resume-AMWorkflow {
    <#
        .SYNOPSIS
            Resumes a failed AutoMate Enterprise workflow.

        .DESCRIPTION
            Resume-AMWorkflow resumse paused workflow and task instances.

        .PARAMETER InputObject
            The workflow(s) to resumse.

        .INPUTS
            Workflows can be supplied on the pipeline to this function.

        .EXAMPLE
            # Resumes a workflow
            Get-AMWorkflow "Failed workflow" | Resume-AMWorkflow

        .NOTES
            Author(s):     : David Seibel
            Contributor(s) :
            Date Created   : 07/26/2018
            Date Modified  : 08/08/2018

        .LINK
            https://github.com/davidseibel/AutoMatePS
    #>
    [CmdletBinding(DefaultParameterSetName = "All",SupportsShouldProcess=$true,ConfirmImpact="High")]
    [OutputType([System.Object[]])]
    param(
        [Parameter(ValueFromPipeline = $true, ParameterSetName = "ByPipeline")]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )
    PROCESS {
        foreach ($obj in $InputObject) {
            switch ($obj.Type) {
                "Workflow" {
                    switch ($obj.ResultCode) {
                        "Failed" {
                            Write-Verbose "Resuming workflow $($obj.Name)."
                            Invoke-AMRestMethod -Resource "workflows/$($obj.ConstructID)/resume" -RestMethod Post -Connection $obj.ConnectionAlias
                        }
                        default {
                            if ($PSCmdlet.ShouldProcess($obj.ConnectionAlias, "$($obj.Type): $(Join-Path -Path $obj.Path -ChildPath $obj.Name) is not in a failed status, and will start from the beginning.")) {
                                Write-Verbose "Starting workflow $($obj.Name)."
                                Invoke-AMRestMethod -Resource "workflows/$($obj.ConstructID)/resume" -RestMethod Post -Connection $obj.ConnectionAlias
                            }
                        }
                    }
                }
                default {
                    Write-Error -Message "Unsupported input type '$($obj.Type)' encountered!" -TargetObject $obj
                }
            }
        }
    }
}