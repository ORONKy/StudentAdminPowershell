. .\GlobalVariables.ps1
. .\MySQL.ps1
. .\Logger.ps1
function createAdGroups {
    param (
        
    )
    $classes = runSql $GlobalDatabaseName "SELECT * FROM klasse" 
    foreach($class in $classes){
        $groupName = "GISO_"+$class[1]
        $groupExisting = Get-ADGroup -Filter "DistinguishedName -eq '$($GlobalGroupOUPath)' -AND Name -eq '$groupName'"
        if (!$groupExisting) {
            $GlobalGroupOUPath
            New-ADGroup -Name $groupName -Path $GlobalGroupOUPath -GroupScope "Global"
            log "ad group created, name: $groupName" "INFO"
        }
    }
}

createAdGroups