
function Get-UserGroupOwners{
    #Parameter to not show groups with no descrption or owner field
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [switch]$hideNoOwner,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$userSamID
    )
    begin{
        $userInfo = Read-Host "Please enter in a username"
        $userSamID = Get-ADUser $userInfo 
    }
    process{
        Get-ADPrincipalGroupMembership $userSamID | ForEach-Object {Get-ADGroup $_ -Properties *} | Select-Object name, description | Format-Table
    }

    end{
    }

}