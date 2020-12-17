

function readXmlGetStudent {
    param (
        [string]$xmlPath = ".\ressources\gibsso_AD-Export.xml"
    )
    [xml]$xmlScoolData = Get-Content -Path $xmlPath
    return $xmlScoolData
   # $xmlScoolData.SelectNodes("//ad")

}
