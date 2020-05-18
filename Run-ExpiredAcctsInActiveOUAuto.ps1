begin{
#define variables
    $ExcludedOU = "OU=Disabled Users,DC=lantheus,DC=local"
    $Recipients = "EMAIL@ADDRESS.COM"
    $FromAddress = "ADReports@DOMAIN.com"
    $Date = (Get-Date).ToString("MM-dd-yyyy")
    $PathToFile = "C:\Path\To\Disabled Accounts in Active OU\ExpiredAcctsInActiveOU$date.csv"
        
}
process{
    #search for expired users
    $ExpiredUsers = Search-ADAccount -AccountExpired -UsersOnly | Where-Object {$_.distinguishedname -notlike $ExcludedOU -and $_.enabled -eq $true}
    
    #loop through expired users to find individual user info
    $Userinfo = foreach($user in $ExpiredUsers){
        Get-ADUser $user.samaccountname -Properties * | Select-Object samaccountname, givenname, surname, AccountExpirationDate, description, manager
    }
    #Create empty array to store an object that contains user info values
    $UsersArray = @()
    #build object to store user values from above
    $UserInfo | ForEach-Object{$temp = New-Object System.Object;
    $temp | Add-Member -Type NoteProperty -Name Username -Value $_.samaccountname;
    $temp | Add-Member -Type NoteProperty -Name "First Name" -Value $_.givenname;
    $temp | Add-Member -Type NoteProperty -Name "Last Name" -Value $_.surname;
    $temp | Add-Member -Type NoteProperty -Name "Expired Date" -Value $_.AccountExpirationDate;
    $temp | Add-Member -Type NoteProperty -Name Description -Value $_.description
    $Manager = ($_.manager -split(','))[0] -replace("CN=","")
    $temp | Add-Member -Type NoteProperty -Name Manager -Value $Manager
    $UsersArray += $temp
    }
    #export to csv
    $UsersArray | Export-Csv $PathToFile
    #email report
    Send-MailMessage -To $Recipients -from $FromAddress -Subject "Expired Users in Active OU Report" -Attachments $PathToFile -SmtpServer "mail.DOMAIN.com"
}
#end