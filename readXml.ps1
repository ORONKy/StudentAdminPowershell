. .\GlobalVariables.ps1

function readXmlGetStudent {
    param (
        [string]$xmlPath = $GlobalXmlPath
    )
    [xml]$xmlScoolData = Get-Content -Path $xmlPath
    return $xmlScoolData
   # $xmlScoolData.SelectNodes("//ad")

}
