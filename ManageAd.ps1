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
            Disable-ADAccount -Identity $adName 
        }
    }
}

function deleteDeletedGroups {
    param (
        
    )
    
}

deactivateDeletedStudents