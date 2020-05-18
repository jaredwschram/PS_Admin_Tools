#my changes to getting a reason why a computer was last rebooted
function Get-ComputerReboot{
    #Create Parameters
    param(
        #computer name
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true, position=0)]
        [string]$ComputerName = $env:COMPUTERNAME,
        #error log 
        [string]$ErrorLog
        )

    #Create variables:
    begin{
        #registry keys
        #if true then pending reboot reason is windows auto update
        $AutoUpdateLocation = "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\"
        #if true then pending reboot reason is role installed
        $CBSEnableLocation = "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\"
        #If true then pending reboot reason is software install - pending file name change
        $FileRenameLocation = "SYSTEM\CurrentControlSet\Control\Session Manager\"

       #hashtable for storing all the values
        $Hashproperty = @{}
        $Selectproperty = @('ComputerName','OSVersion','LastBootUpTime','ComponentBasedService','AutoUpdate','FileRename','FileRenameVal')
        } 

    process{
        foreach($Computer in $ComputerName){
            #start try/catch block
            try{
                #establish remote registry connection if fails catch error and report server
                $Hive = [UInt32] "0x80000002"
                $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"

      
                #query against Windows Auto Update Key
                $AutoUpdateRegKey = $WMI_Reg.EnumKey($Hive,$AutoUpdateLocation)
                $AutoUpdateRebootReq = $AutoUpdateRegKey.sNames -contains "RebootRequired"
                #query against role installed or component based servicing
                $CBSKey = $WMI_Reg.EnumKey($Hive,$CBSEnableLocation)
                $CBSRebootReq = $CBSKey.sNames -contains "RebootPending"
                #query against pending filename
                $FileRenameRegKey = $WMI_Reg.GetMultiStringValue($Hive,$FileRenameLocation,"PendingFileRenameOperations")
                $FileRenameRebootValue = $FileRenameRegKey.sValue
                
                #Set FileRenameTrue to false unless FileNameRebootReq has a value then say true for pending file name
                $FileRenameTrue = $false
                if($null -ne $FileRenameRebootValue){
                    $FileRenameTrue = $true
                }

                #query wmiobject win32_operatingsystem to find lastbootuptime and convert to human readable format with .Net
                $UptimeForHumans = [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer).LastBootUpTime)

                #Get OS version
                $OSVersion = Get-ADComputer $Computer -Properties operatingsystem | Select-Object -ExpandProperty operatingsystem


                #create custom psobject and select object to build hashtable for
                $Hashproperty.ComputerName = $Computer
                $Hashproperty.OSVersion = $OSVersion
                $Hashproperty.LastBootUpTime = $UptimeForHumans
                $Hashproperty.ComponentBasedService = $CBSRebootReq
                $Hashproperty.AutoUpdate = $AutoUpdateRebootReq
                $Hashproperty.FileRename = $FileRenameTrue
                $Hashproperty.FileRenameVal = $FileRenameRebootValue
                New-Object -TypeName PSCustomObject -Property $Hashproperty |
                Select-Object -Property $Selectproperty

            }#End of Try block

            #catch error if registry connection failed
            catch{
                Write-Warning "$Computer' : $_"
                if ($ErrorLog) {
                        Out-File -InputObject "$Computer',$_" -FilePath $ErrorLog -Append                       
                }
            }
        }
    }
}