. .\MySQL.ps1
. .\GlobalVariables.ps1
. .\Logger.ps1

function deactivateDeletedStudents {
    param (
        
    )
    $dbStudents = runSql $GlobalDatabaseName "SELECT * FROM schueler"
    $adStudents = Get-ADUser -Filter * -SearchBase $GlobalStudentOUPath

    foreach($adStudent in $adStudents){
        $adName = $adStudent.Name
        [bool]$isUserInADAndInDB = 0
        foreach($dbStudent in $dbStudents ){
            $dbStudentMax20 = nameMax20Chars $dbStudent[1]
            
            if ($adName -eq $dbStudentMax20) {
                $isUserInADAndInDB = 1
                break
            }
        }
        if (!$isUserInADAndInDB) {
            Disable-ADAccount -Identity $adName
            log "account disabled, username: $adName" "INFO"
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
        Get-ADGroup -Identity $adName | Remove-ADGroup -Confirm:$false
        log "adGroup removed, name: $adName" "INFO"
    }
}
   
}

function addUserToGroup {
    param (
    )
            $querry = "SELECT schueler.username, klasse.klassenbezeichnung FROM schueler
            INNER JOIN ``schueler-klasse`` ON schueler.sid = ``schueler-klasse``.sid
            INNER JOIN klasse ON klasse.kid = ``schueler-klasse``.kid"
            $dbStudentGroupNameAssigne = runSql $GlobalDatabaseName $querry
            foreach($assigne in $dbStudentGroupNameAssigne)
            {
                $groupname= "GISO_$($assigne[1])"

                $nameMax20 = nameMax20Chars $assigne[0]
                $adUser = GET-ADUser -Filter "Name -eq '$nameMax20'" -SearchBase $GlobalStudentOUPath                
                try {
                    Get-ADGroup -Filter "Name -eq '$groupname'" -SearchBase $GlobalGroupOUPath | Add-ADGroupMember -Members $adUser
                    log "user added to group, user: $($adUser.name), group: $groupname" "INFO"
                }
                catch {
                    log "cant add user to Group $($adUser.name), group: $groupname, message: $_"
                }
            }
}

function removeOldAdGroupsFromStudent {
    param (
    )
    $dbStudents = runSql $GlobalDatabaseName "SELECT username FROM schueler"
    foreach($dbStudent in $dbStudents){
        try {
            $nameMax20 = nameMax20Chars $dbStudent[0]
            $currentlyGroupMember = Get-ADPrincipalGroupMembership -Identity $nameMax20
        }
        catch {
            
        }
        [bool]$isAdGroupInDB = $false
        foreach($group in $currentlyGroupMember)
        {
            if ($group.DistinguishedName -like "*$GlobalGroupOUPath") {
                $querry = "SELECT schueler.username, klasse.klassenbezeichnung FROM schueler
                INNER JOIN ``schueler-klasse`` ON schueler.sid = ``schueler-klasse``.sid
                INNER JOIN klasse ON klasse.kid = ``schueler-klasse``.kid
                WHERE schueler.username = '$($dbStudent[0])'"
                $dbStudentGroupAssigne = runSql $GlobalDatabaseName $querry
                foreach($dbGroup in $dbStudentGroupAssigne)
                {   
                    $dbToAdGroupName = "GISO_$($dbGroup[1])"         
                    if ($group.name -eq $dbToAdGroupName) {
                        $isAdGroupInDB = $true
                    }
                }
                if (!$isAdGroupInDB -And -not($group.DistinguishedName -eq $GlobalGroundDC )) {
                        $adMember = Get-ADUser -Identity $nameMax20
                        Remove-ADGroupMember -Members $adMember -Identity $group.name -confirm:$false
                        log "group removed from user, user: $nameMax20, group: $($group.name)"
                }
            }
        }
    }
}

function nameMax20Chars {
    param (
        $name
    )
    if ($name.length -gt 20) {
        $name = $name.subString(0,20)
        if ($name -eq "dominiclucienjerome.") {
        }
        if ($name[19] -eq ".") {
            $name = $name.subString(0,19)
        }
    }
    return $name
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
addUserToGroup
removeOldAdGroupsFromStudent
