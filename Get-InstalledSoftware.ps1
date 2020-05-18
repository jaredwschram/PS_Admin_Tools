Function Get-InstalledSoftware {
    param(
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0
        )]
        [string]$ComputerName = $env:COMPUTERNAME
    )

    begin {
        $RegistryLocations = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\',
                            'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'

        $HashProperty = @{}
        $SelectProperty = @('ComputerName','ProgramName')

    }

    process {
        foreach ($Computer in $ComputerName) {
                $RegConnection = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Computer)
                    
                $RegistryLocations | ForEach-Object {
                    $CurrentRegValue = $_
                    if ($RegConnection) {
                        $CurrentRegKey = $RegConnection.OpenSubKey($CurrentRegValue)
                        if ($CurrentRegKey) {
                            $CurrentRegKey.GetSubKeyNames() | ForEach-Object {
                            $HashProperty.ComputerName = $Computer
                            $HashProperty.ProgramName = ($DisplayName = ($RegConnection.OpenSubKey("$CurrentRegValue$_")).GetValue('DisplayName'))
                                if ($DisplayName) {
                                    if ($Property) {
                                        foreach ($CurrentProperty in $Property) {
                                            $HashProperty.$CurrentProperty = ($RegConnection.OpenSubKey("$CurrentRegValue$_")).GetValue($CurrentProperty)
                                        }
                                    }
                                    New-Object -TypeName PSCustomObject -Property $HashProperty |
                                    Select-Object -Property $SelectProperty
                                    }
                                }
                            }
                        }   
                    }
                }
        }
    }
