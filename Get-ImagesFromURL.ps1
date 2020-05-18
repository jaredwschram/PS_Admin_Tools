<#
creates array of strings containing URLs from a CSV then splits off the URI for each and saves file location and name to new file
#>
function Get-ImagesFromURL{
    begin{
    $listOfURLS = Get-Content -path (Read-Host -prompt "Enter Path to CSV")
    $webClient = New-Object System.Net.WebClient
    #Modify the path to determine where pictures are going to be SAVED
    $picturePath = "C:\Path\To\Files"
    
    }
    process{
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        foreach($url in $listOfURLS){
            #pictureName cuts off the URI to only have pictureName.EXT may need to adjust what gets cut
            $pictureName = $url.split('/')[-1].split('?')[0]
            $webClient.DownloadFile($url, "$picturePath\$pictureName")
        }
    }
}
