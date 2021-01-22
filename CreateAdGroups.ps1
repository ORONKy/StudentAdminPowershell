. .\GlobalVariables.ps1
. .\MySQL.ps1
. .\Logger.ps1
function createAdGroups {
    param (
        
    )
    $classes = runSql $GlobalDatabaseName "SELECT * FROM klasse" 
    foreach($class in $classes){
        $groupName = "GISO_"+$class[1]
        $asdf = isGroupExisting $groupName
        if (!($asdf)) {
            New-ADGroup -Name $groupName -Path $GlobalGroupOUPath -GroupScope "Global"
            log "ad group created, name: $groupName" "INFO"
        }
    }
}

function isGroupExisting {
    param (
        $GroupADName
    )
    try {
        $group = Get-ADGroup -Identity $GroupADName
    }
    catch {
    }
    if ($group) {
        return $true
    }
    return $false
}
createAdGroups