function Get-AMSystemPermission {
    <#
        .SYNOPSIS
            Gets AutoMate Enterprise system permissions.

        .DESCRIPTION
            Get-AMSystemPermission gets system permissions.

        .PARAMETER InputObject
            The object(s) to retrieve permissions for.

        .PARAMETER FilterSet
            The parameters to filter the search on.  Supply hashtable(s) with the following properties: Property, Comparator, Value.
            Valid values for the Comparator are: =, !=, <, >, contains (default - no need to supply Comparator when using 'contains')

        .PARAMETER FilterSetMode
            If multiple filter sets are provided, FilterSetMode determines if the filter sets should be evaluated with an AND or an OR

        .PARAMETER SortProperty
            The object property to sort results on.  Do not use ConnectionAlias, since it is a custom property added by this module, and not exposed in the API.

        .PARAMETER SortDescending
            If specified, this will sort the output on the specified SortProperty in descending order.  Otherwise, ascending order is assumed.

        .PARAMETER Connection
            The AutoMate Enterprise management server.

        .INPUTS
            Permissions for the following objects can be retrieved by this function:
            User
            UserGroup

        .OUTPUTS
            SystemPermission

        .EXAMPLE
            # Get permissions for user "MyUsername"
            Get-AMUser "MyUsername" | Get-AMSystemPermission

        .EXAMPLE
            # Get permissions using filter sets
            Get-AMSystemPermission -FilterSet @{Property = 'EditDefaultPropertiesPermission'; Comparator = '='; Value = 'true'}

        .NOTES
            Author(s):     : David Seibel
            Contributor(s) :
            Date Created   : 07/26/2018
            Date Modified  : 08/08/2018

        .LINK
            https://github.com/davidseibel/AutoMatePS
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Position = 0, ParameterSetName = "ByPipeline", ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        [Hashtable[]]$FilterSet,

        [ValidateSet("And","Or")]
        [string]$FilterSetMode = "And",

        [ValidateNotNullOrEmpty()]
        [string[]]$SortProperty = "GroupID",

        [switch]$SortDescending = $false,

        [ValidateNotNullOrEmpty()]
        $Connection
    )

    BEGIN {
        $splat = @{
            RestMethod = "Get"
        }
        if ($PSBoundParameters.ContainsKey("Connection")) {
            $Connection = Get-AMConnection -Connection $Connection
            $splat += @{Connection = $Connection}
        }
        $result = @()
    }

    PROCESS {
        switch($PSCmdlet.ParameterSetName) {
            "All" {
                $splat += @{ Resource = Format-AMUri -Path "system_permissions/list" -FilterSet $FilterSet -FilterSetMode $FilterSetMode -SortProperty $SortProperty -SortDescending:$SortDescending.ToBool() }
                $result = Invoke-AMRestMethod @splat
            }
            "ByPipeline" {
                foreach ($obj in $InputObject) {
                    Write-Verbose "Processing $($obj.Type) '$($obj.Name)'"
                    $tempSplat = $splat
                    if (-not $tempSplat.ContainsKey("Connection")) {
                        $tempSplat += @{ Connection = $obj.ConnectionAlias }
                    } else {
                        $tempSplat["Connection"] = $obj.ConnectionAlias
                    }
                    Write-Verbose "Processing $($obj.Type) '$($obj.Name)'"
                    switch ($obj.Type) {
                        {($_ -in @("User","UserGroup"))} {
                            $tempFilterSet = $FilterSet + @{Property = "GroupID"; Comparator = "="; Value = $obj.ID}
                            $tempSplat += @{ Resource = Format-AMUri -Path "system_permissions/list" -FilterSet $tempFilterSet -FilterSetMode $FilterSetMode -SortProperty $SortProperty -SortDescending:$SortDescending.ToBool() }
                            $result += Invoke-AMRestMethod @tempSplat
                        }
                        default {
                            $unsupportedType = $obj.GetType().FullName
                            if ($_) { 
                                $unsupportedType = $_ 
                            } elseif (-not [string]::IsNullOrEmpty($obj.Type)) {
                                $unsupportedType = $obj.Type
                            }
                            Write-Error -Message "Unsupported input type '$unsupportedType' encountered!" -TargetObject $obj
                        }
                    }
                }
            }
        }
    }

    END {
        $SortProperty += "ConnectionAlias", "ID"
        return $result | Sort-Object $SortProperty -Unique -Descending:$SortDescending.ToBool()
    }
}