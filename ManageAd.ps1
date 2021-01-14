. .\MySQL.ps1
. .\GlobalVariables.ps1

function deactivateDeletedStudents {
    param (
        
    )
    $dbStudents = runSql $GlobalDatabaseName "SELECT * FROM schueler"
    $adStudents = Get-ADUser -Filter * -SearchBase $GlobalStudentOUPath

    foreach($adStudent in $adStudents){
        $adName = $adStudent.Name
        [bool]$isUserInADAndInDB = 0
        foreach($dbStudent in $dbStudents ){
            if ($adName -eq $dbStudent[1]) {
                $isUserInADAndInDB = 1
            }
        }
        if (!$isUserInADAndInDB) {
            Disable-ADAccount -Identity $adName -Filter ""
        }
    }
}

function deleteDeletedGroups {
    param (
        
    )
   $adGroups = Get-ADGroup -Filter * -SearchBase $GlobalGroupOUPath
   $dbGroups = runSql $GlobalDatabaseName "SELECT * FROM Klasse"

   foreach($adGroup in $adGroups){
    $adName = $adGroup.Name
    [bool]$isGroupInADAndInDB = 0
    foreach($dbGroup in $dbGroups ){
        if ($adName -eq $dbGroup[1]) {
            $isGroupInADAndInDB = 1
        }
    }
    if (!$isGroupInADAndInDB) {
        Remove-ADGroup -Identity $adName 
    }
}
    
}

deleteDeletedGroups
deactivateDeletedStudents