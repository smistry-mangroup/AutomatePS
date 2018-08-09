function Remove-AMUserGroupMember {
    <#
        .SYNOPSIS
            Removes users from an AutoMate Enterprise user group.

        .DESCRIPTION
            Remove-AMUserGroupMember can remove users from a user group.

        .PARAMETER InputObject
            The user group to modify.

        .PARAMETER User
            The users(s) to remove from the user group.

        .INPUTS
            The following AutoMate object types can be modified by this function:
            UserGroup

        .OUTPUTS
            None

        .EXAMPLE
            # Remove all users from a user group
            Get-AMUserGroup "All Users" | Remove-AMUserGroupMember -User *

        .EXAMPLE
            # Remove a user from a user group (using user object)
            Get-AMUserGroup | Remove-AMUserGroupMember -User (Get-AMUser "David")

        .NOTES
            Author(s):     : David Seibel
            Contributor(s) :
            Date Created   : 07/26/2018
            Date Modified  : 08/08/2018

        .LINK
            https://github.com/davidseibel/AutoMatePS
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject,

        [Parameter(Mandatory = $true, Position = 0)]
        $User
    )
    PROCESS {
        foreach ($obj in $InputObject) {
            if ($obj.Type -eq "UserGroup") {
                $update = Get-AMUserGroup -ID $obj.ID -Connection $obj.ConnectionAlias
                $shouldUpdate = $false
                foreach ($u in $User) {
                    if ($u.PSObject.Properties.Name -contains "Type") {
                        if ($u.Type -ne "User") {
                            throw "Unsupported input type '$($u.Type)' encountered!"
                        }
                    } elseif ($u -is [string]) {
                        $tempUser = Get-AMUser -Name $u -Connection $obj.ConnectionAlias
                        if ($tempUser) {
                            $u = $tempUser
                        } else {
                            throw "User '$u' not found!"
                        }
                    }
                    if ($update.UserIDs -contains $u.ID) {
                        $update.UserIDs = @($update.UserIDs | Where-Object {$_ -ne $u.ID})
                        Write-Verbose "Removing user '$($u.Name)' from user group '$($obj.Name)'."
                    } else {
                        Write-Verbose "User '$($u.Name)' not present in user group '$($obj.Name)'."
                    }
                }
                if (($update.UserIDs | Measure-Object).Count -eq 0) {
                    $update.UserIDs = @()
                }
                if ($shouldUpdate) {
                    $update | Set-AMObject
                    Write-Verbose "Completed removing users from user group '$($obj.Name)'."
                }
            } else {
                Write-Error -Message "Unsupported input type '$($obj.Type)' encountered!" -TargetObject $obj
            }
        }
    }
}