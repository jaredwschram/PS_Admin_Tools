begin{
    #define domain admin group
    $DomAdmGrp = "Domain Admins"
    #define email recipients
    $Recipients = "EMAIL@ADDRESS.com"
    $FromAddress = "ADReports@DOMAIN.com"
    $Date = (Get-Date).ToString("MM-dd-yyyy")
    $PathToFile = "C:\Path\To\DomainAdminMembers$date.csv"
}

process{
    #find admin group members
    $DomAdmGrpMembers = Get-ADGroupMember $DomAdmGrp

    #find user info on admin group members
    $UserInfo = foreach($member in $DomAdmGrpMembers){
        #find user info on domain admgrp members
        Get-ADUser $member.samaccountname -Properties * | Select-Object samaccountname, givenname, surname, title, department, manager, Description

    }
    #Create empty array to store an object that contains user info values
    $UsersArray = @()
    #build object to store user values from above
    $UserInfo | ForEach-Object{$temp = New-Object System.Object;
    $temp | Add-Member -Type NoteProperty -Name Username -Value $_.samaccountname;
    $temp | Add-Member -Type NoteProperty -Name "First Name" -Value $_.givenname;
    $temp | Add-Member -Type NoteProperty -Name "Last Name" -Value $_.surname;
    $temp | Add-Member -Type NoteProperty -Name Title -Value $_.title;
    $temp | Add-Member -Type NoteProperty -Name Department -Value $_.department;
    $Manager = ($_.manager -split(','))[0] -replace("CN=","")
    $temp | Add-Member -Type NoteProperty -Name Manager -Value $Manager
    $temp | Add-Member -Type NoteProperty -Name Description -Value $_.Description
    $UsersArray += $temp
    }
    #store to csv
    $UsersArray | Export-Csv $PathToFile
    #email to recipients
    Send-MailMessage -To $Recipients -from $FromAddress -Subject "Domain Admin Report" -Attachments $PathToFile -SmtpServer "mail.DOMAIN.com"
    
}
#end