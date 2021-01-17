. .\GlobalVariables.ps1

function readXml {
    param (
        [string]$xmlPath = $GlobalXmlPath
    )
    [xml]$xmlScoolData = Get-Content -Path $xmlPath -Encoding UTF8
    return $xmlScoolData
   # $xmlScoolData.SelectNodes("//ad")
}




