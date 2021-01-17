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
            $dbStudentMax20 = $dbStudent[1].subString(0,20)
            if ($adName -eq $dbStudentMax20) {
                $isUserInADAndInDB = 1
            }
        }
        if (!$isUserInADAndInDB) {
            Disable-ADAccount -Identity $adName
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
        $dbToAdName= "GISO_$($dbGroup[1])"
        if ($adName -eq $dbToAdName) {
            $isGroupInADAndInDB = 1
        }
    }
    if (!$isGroupInADAndInDB) {
        ##search scope added
        Get-ADGroup -Identity $adName | Remove-ADGroup
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

function removeOldAdGroupsFromStudent {
    param (
    )
    $querry = "SELECT schueler.username, klasse.klassenbezeichnung FROM schueler
    INNER JOIN `schueler-klasse` ON schueler.sid = `schueler-klasse`.sid
    INNER JOIN klasse ON klasse.kid = `schueler-klasse`.kid"
    $dbStudentGroupAssigne = runSql $GlobalDatabaseName $querry
    $dbStudents = runSql $GlobalDatabaseName "SELECT username FROM schueler"
    foreach($dbStudent in $dbStudents){
        $currentlyGroupMember = Get-ADPrincipalGroupMembership -Identity $dbStudent[1]
        [bool]$isAdGroupInDB = $false
        foreach($group in $currentlyGroupMember)
        {
            foreach($dbGroup in ($dbStudentGroupAssigne | Where-Object $_[0] -eq $dbStudent[1]))
            {            
                if ($group.name -eq $dbGroup[1]) {
                    $isAdGroupInDB = $true
                }
            }

        }
        if (!$isAdGroupInDB) {
            $adMember = Get-ADUser -Identity $dbStudent[1]
            $group | Remove-ADGroupMember -Members $adMember
        }
    }
}

function removeEmptyGroups {
    param (
    )
    Get-ADGroup -SearchBase $GlobalGroupOUPath | ForEach-Object {
        if (($_ | Get-ADGroupMember).size() -eq 0  ) {
            $_ | Remove-ADGroup
        }
    }
}



deleteDeletedGroups
deactivateDeletedStudents
removeOldAdGroupsFromStudent
