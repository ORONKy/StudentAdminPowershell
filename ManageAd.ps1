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
        ##search scope added
        Remove-ADGroup -Identity $adName -SearchScope $GlobalGroupOUPath
    }
}
   
}

function addUserToGroup {
    param (
    )
            $querry = "SELECT schueler.username, klasse.klassenbezeichnung FROM schueler
            INNER JOIN `schueler-klasse` ON schueler.sid = `schueler-klasse`.sid
            INNER JOIN klasse ON klasse.kid = `schueler-klasse`.kid"
            $dbStudentGroupNameAssigne = runSql $GlobalDatabaseName $querry
            foreach($assigne in $dbStudentGroupNameAssigne)
            {
                $adUser = GET-ADUser -Identity $assigne[0] -SearchScope $GlobalStudentOUPath
                Get-ADGroup -Identity $assigne[1] -SearchScope $GlobalGroupOUPath | Add-ADGroupMember $adUser
            }

}

deleteDeletedGroups
deactivateDeletedStudents