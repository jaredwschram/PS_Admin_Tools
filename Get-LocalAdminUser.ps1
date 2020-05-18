function Get-localAdminUser{
#declare script parameters
    param(
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true, position=0)]
        [string]$ComputerName = $env:COMPUTERNAME,
        [string]$ErrorLog
        )

    begin{
        $FilterSID = "NOT SID = 'S-1-5-18' AND NOT SID = 'S-1-5-19' AND NOT SID = 'S-1-5-20' AND NOT SID = 'S-1-5-21-2792496554-3264945058-473949537-500'"
        $Hash = @{}
        $Props = @('Computer','FirstName','LastName','User','HasAdmin')
        }
process{
    #start for loop against each workstation
    foreach($computer in $ComputerName){
        try{
            #Get user info of last 2 users to log on | Ideally we only want 1 user but unfortunately using LastUseTime isn't the best way to do this and this script was needed ASAP at time of creation
            $AllUsersOnComputer = Get-WmiObject -Class Win32_UserProfile -Filter $FilterSID -ComputerName $computer
            $RecentUsers = $AllUsersOnComputer | Sort-Object -Property LastUseTime -Descending | Select-Object -First 1 |Select-Object -ExpandProperty LocalPath

            #Since we needed to grab the most recent 2 users instead of only one we need to loop through each to split the usernames into usable format(should've used SID)
            $RecentUsersComplete = foreach($user in $RecentUsers){
                ($user -replace 'C:\\Users\\','DOMAIN\')
                }
            #pull the local admin group on the remote machine
            $LocalAdmin = Invoke-Command -ComputerName $computer -ScriptBlock {Get-LocalGroupMember administrators}
            
            $UsersGivenName = $RecentUsersComplete | ForEach-Object{($_ -replace("DOMAIN\\",""))} | ForEach-Object {Get-ADUser $_} | Select-Object -ExpandProperty givenname
            $UsersSurName = $RecentUsersComplete | ForEach-Object{($_ -replace("DOMAIN\\",""))} | ForEach-Object {Get-ADUser $_} | Select-Object -ExpandProperty surname
                #Loop through each Completed username to see if localadmin.name contains the value and then return the username if so
                $UsersWithAdminTrue = $RecentUsersComplete | ForEach-Object{
                    if($LocalAdmin.name -contains $_){
                        #Create hash table
                        $True
                        }
                    else{
                        $False
                        }
                }
                
                $Hash.Computer = $computer
                $Hash.FirstName = $UsersGivenName
                $Hash.LastName = $UsersSurName
                $Hash.User = $RecentUsersComplete
                $Hash.HasAdmin = $UsersWithAdminTrue
                New-Object -TypeName PSCustomObject -Property $Hash |
                    Select-Object -Property $Props

            }#End of Try
        catch{
            Write-Warning "$ComputerName' : $_"
                if ($ErrorLog) {
                    Out-File -InputObject "$ComputerName',$_" -FilePath $ErrorLog -Append 
                    }
            }
        }   
    }
}
