function Find-AMObject {
    <#
        .SYNOPSIS
            Finds objects in AutoMate Enterprise.

        .DESCRIPTION
            Find-AMObject searches AutoMate Enterprise for objects based on a search query.

        .PARAMETER Pattern
            The pattern to use when searching.  Regular expressions are supported.

        .PARAMETER Regex
            Specify if the -Pattern parameter is a regular expression.  Otherwise, normal wildcards are used.

        .PARAMETER Type
            The object type(s) to perform search against.

        .PARAMETER SearchDepth
            The number of layers (sub-objects/properties) in every object to search.  Using a search depth that is too deep can significantly increase search time.

        .PARAMETER Connection
            The server to perform search against.

        .EXAMPLE
            # Find all tasks that have FTP activities
            Find-AMObject -Pattern "AMFTP" -Type Task

        .NOTES
            Author(s):     : David Seibel
            Contributor(s) :
            Date Created   : 07/26/2018
            Date Modified  : 08/08/2018

        .LINK
            https://github.com/davidseibel/AutoMatePS
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Pattern,

        [switch]$Regex = $false,

        [ValidateSet("Workflow","Task","Condition","Process","TaskAgent","ProcessAgent","AgentGroup","User","UserGroup")]
        [string[]]$Type = @("Workflow","Task","Condition","Process","TaskAgent","ProcessAgent","AgentGroup","User","UserGroup"),

        [ValidateScript({$_ -gt 0})]
        [int]$SearchDepth = 3,

        [ValidateNotNullOrEmpty()]
        $Connection
    )

    $splat = @{
        RestMethod = "Get"
    }
    if ($PSBoundParameters.ContainsKey("Connection")) {
        $Connection = Get-AMConnection -Connection $Connection
        $splat.Add("Connection",$Connection)
    }

    # Retrieve all objects of the specified types
    $toSearch = @()
    foreach ($t in $Type) {
        $tempSplat = $splat
        $tempSplat += @{ Resource = "$(([AMTypeDictionary]::($t)).RestResource)/list?sort_field=Name" }
        $toSearch += Invoke-AMRestMethod @tempSplat
    }

    # Recursively search properties of objects
    $searchResult = $toSearch | Search-ObjectProperty -Pattern $Pattern -Regex:$Regex
    $searchResult | Foreach-Object {$_.PSObject.TypeNames.Insert(0,"CustomFoundObject")}

    return $searchResult
}