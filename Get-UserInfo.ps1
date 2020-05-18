function Get-UserInfo{
  #Switch parameter to check for enbaled users only or not
  param(
      [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
      [switch]$Enabled
  )
#Prompt tech to enter in search criteria
$Surname = Read-Host "Enter the user's last name or hit enter if you don't have it."
$Givenname = Read-Host "Enter the user's first name or hit enter if you don't have it."

#IF/ELSEIF/ELSE logic to determine what filter to apply to get-aduser
  if($Givenname -eq '' ){
        if($Enable -eq $True){
            Get-ADUser -Filter {surname -like $Surname -and enabled -eq "True"} -Properties * | Select-Object givenname, surname, emailaddress, title, department, manager, samaccountname| Format-List
          }
        else {
            Get-ADUser -Filter {Surname -like $Surname} -Properties * | Select-Object givenname, surname, emailaddress, title, department, manager, samaccountname, enabled | Format-List
          }
    }
  elseif($Surname -eq ''){
    if ($Enabled -eq $true) {
        Get-ADUser -Filter {givenname -like $Givenname -and enabled -eq "True"} -Properties * | Select-Object givenname, surname, emailaddress, title, department, manager, samaccountname| Format-List            
      }
    else {
        Get-ADUser -Filter {givenname -like $Givenname} -Properties * | Select-Object givenname, surname, emailaddress, title, department, manager, samaccountname, enabled | Format-List
      }   
    }
  else{
    if ($Enabled -eq $true) {
        Get-ADUser -Filter {surname -like $Surname -and givenname -like $Givenname -and enabled -eq "True"} -Properties * | Select-Object givenname, surname, emailaddress, title, department, manager, samaccountname | Format-List
      }
    else {
        Get-ADUser -Filter {surname -like $Surname -and givenname -like $Givenname} -Properties * | Select-Object givenname, surname, emailaddress, title, department, manager, samaccountname, enabled | Format-List
      }
    }
}