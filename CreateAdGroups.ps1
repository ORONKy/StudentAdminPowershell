. .\GlobalVariables.ps1
. .\MySQL.ps1

function createAdGroups {
    param (
        
    )
    $classes = runSql $GlobalDatabaseName "SELECT * FROM klasse" 
    foreach($class in $classes){
        $groupName = "GISO_"+$class[1]
        $groupExisting = Get-ADGroup -Identity $groupName -Filter "DistinguishedName -eq $($GlobalGroupOUPath)"
        if (!$groupExisting) {
            New-ADGroup -Name $groupName -Path $GlobalGroupOUPath 
        }
    }


}