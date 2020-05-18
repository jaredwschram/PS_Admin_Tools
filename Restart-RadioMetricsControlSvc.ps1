#Jared Schram - Script to restart a specific service on a remote machine as a specific user
#security precautions must be taken to encrypt Asset files for $psatU and $psatP. Key file is used 
#$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.size(140,25)
$Host.UI.RawUI.BackgroundColor = 'Black'
$Host.UI.RawUI.ForegroundColor = 'Cyan'
$cpu = 'HOSTNAME or IP'
$svc = Get-Service -ComputerName $cpu  -Name SERVICENAME

Write-Host 'This script is to restart the SERVICENAME service on HOSTNAME as per KB#### for ISSUE TITLE.'
Write-Host ' '
Write-Host 'If you did not receive a call/ticket from TEAM NAME or you are unsure of what this is for please (Q)uit out of this now.'
Write-Host ' '
Write-Host 'Otherwise please press (R) to restart the SERVICENAME service.'
Write-Host '--------------------------------------'
$option = Read-Host -Prompt ' '
Write-Host ' '
while($option -ne 'Q' -or $option -ne 'C' -or $option -ne 'R'){
    switch($option){
        Q{
            Write-Host 'Exiting script now' -ForegroundColor Magenta
            Write-Host ' '
            Start-Sleep -Seconds 3
            exit    
        }R{
            Write-Host 'You have selected to restart the SERVICENAME service, are you sure this is what you want to do? (Y)es or (N)o'
            Write-Host '--------------------------------------'
            $sanity = Read-Host -Prompt ' '
            Write-Host ' '
            Do{
                if($sanity -eq 'Y'){
                    Write-Host 'Restarting SERVICENAME service now please wait.' -ForegroundColor Magenta
                    Write-Host ' '
                    Start-Sleep -Seconds 2
                    #stop service
                    $psatU = Get-Content C:\PATH\TO\SCRIPTS\script_Dependencies\dbaAsset3.tmp
                    $psatP = Get-Content C:\PATH\TO\SCRIPTS\script_Dependencies\dbaAsset1.tmp | ConvertTo-SecureString -Key (Get-Content -Path C:\PATH\TO\SCRIPTS\script_Dependencies\dbaAsset2.tmp)
                    $crd = New-Object -TypeName System.Management.Automation.PSCredential $psatU,$psatP
                    Invoke-Command -ComputerName $cpu -Credential $crd -ScriptBlock {Stop-Service -Name Canberra.Apex.ProxyManager} -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 4
                    #check service is stopped
                    $svc.Refresh()
                    # if($svc.status -like 'Running'){
                    #     #MORE WORK NEEDED
                    #     #wait and then check again
                    # }
                    #start service
                    Invoke-Command -ComputerName $cpu -Credential $crd -ScriptBlock{Start-Service -Name Canberra.Apex.ProxyManager} -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 3
                    $svc.Refresh()
                    #check service again and if running notify service has successfully restarted
                    if($svc.Status -like 'Running'){
                        Write-Host 'The SERVICENAME service has successfully been restarted, please press (Q) to quit the restart script now.'
                        Write-Host '--------------------------------------'
                        $option = Read-Host -Prompt ' '
                        Write-Host ' '
                    }else{
                        #else if not running continue to wait
                        Write-Host 'Service not yet started waiting and attempting to start again.' -ForegroundColor Magenta
                        Write-Host ' '
                        Start-Sleep -Seconds 5
                        $svc.Refresh()
                        Start-Sleep -Seconds 2
                        #if still not running notify user to escalate
                        if($svc.Status -like 'Stopped'){
                            Write-Host 'The service is still stopped, please escalate to your team lead citing that the SERVICENAME service has not successfully recovered on HOSTNAME after being restarted. Press (Q) to quit now.'
                            Write-Host '--------------------------------------'
                            $option = Read-Host -Prompt ' '
                            Write-Host ' '
                        }else{
                            Write-Host 'The service has successfully recovered. please press (Q) to quit the restart script now.'
                            Write-Host '--------------------------------------'
                            $option = Read-Host -Prompt ' '
                            Write-Host ' '
                        }
                    }
                    $sanity = 'n'   
                }elseif($sanity -eq 'N'){
                    Write-Host 'You selected (N) please press (Q) to confirm and quit or (R) to restart?'
                    Write-Host '--------------------------------------'
                    $option = Read-Host ' '
                    Write-Host ' '
                }else{
                    Write-Host 'Please enter a valid option - Note only the letter is required' -ForegroundColor Green
                    Write-Host '--------------------------------------'
                    $sanity = Read-Host ' '
                    Write-Host ' '
                }
            }while($sanity -ne 'N')
        # }C{
        #     Write-Host 'Option C is still under development please choose to (R)estart or (Q)uit for now.' -ForegroundColor Magenta
        #     Write-Host '--------------------------------------'
        #     $option = Read-Host ' '
        #     Write-Host ' '
         }default{
            Write-Host 'Please enter a valid option - Note only the letter is required' -ForegroundColor Green
            Write-Host '--------------------------------------'
            $option = Read-Host ' '
            Write-Host ' '
        }
    }
}