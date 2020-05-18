$Date = (Get-Date).ToString("MM-dd-yyyy")
$PathToFile = "C:\Path\To\AccountsExpiring60Days$Date.csv"
function mailMessage{
    $dba = Import-Csv C:\Path\To\adReportingEmails.csv
    $pass = Get-Content C:\Path\To\pass.txt | ConvertTo-SecureString
    $cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist ('DOMAIN\schramj',$pass)
    foreach($usr in $dba.name){
        Send-MailMessage -To $usr -from 'iGiveYouAD_Reports@domain.com' -subject 'Expiring AD Accounts' -Attachments $PathToFile -SmtpServer smtp.DOMAIN.com -Credential $cred
    }
}
#find users that expire in 60 days and then grab their AD info
$ExpiringUsers = Search-ADAccount -AccountExpiring -TimeSpan "60" 
$UserInfo = foreach($User in $ExpiringUsers) {
    Get-ADUser $User.samaccountname -Properties * | Select-Object SamAccountName, GivenName, Surname, AccountExpirationDate, Description, Manager
    }
$UsersArray = @()
foreach($usr in $UserInfo){
    #Description field contains a note about status of user.
    if($usr.description -notlike "*delete*"){
        $temp = New-Object System.Object;
        $temp | Add-Member -Type NoteProperty -Name Username -Value $usr.samaccountname;
        $temp | Add-Member -Type NoteProperty -Name "First Name" -Value $usr.givenname;
        $temp | Add-Member -Type NoteProperty -Name "Last Name" -Value $usr.surname;
        $temp | Add-Member -Type NoteProperty -Name "Expired Date" -Value $usr.AccountExpirationDate;
        $temp | Add-Member -Type NoteProperty -Name Description -Value $usr.description
        $Manager = ($usr.manager -split(','))[0] -replace("CN=","")
        $temp | Add-Member -Type NoteProperty -Name Manager -Value $Manager
        $UsersArray += $temp    
    }
}  
$UsersArray | export-csv $PathToFile
mailMessage