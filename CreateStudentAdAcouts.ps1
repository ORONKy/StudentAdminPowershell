. .\GlobalVariables.ps1
. .\MySQL.ps1
. .\Logger.ps1

function createAdStudent {
    param (
        
    )

    $students = runSql $GlobalDatabaseName "SELECT * FROM schueler"
    foreach($student in $students){
        $username = $student[1]
        $wthf = isAdUserExisting $username
        if ($wthf[1] -eq 0) {
            $password = ConvertTo-SecureString $GlobalFirstStudentPassword -AsPlainText -Force
            New-ADUser -AccountPassword $password -Path $GlobalStudentOUPath -Name $username -Surname $student[3] -GivenName $student[4]
            log "New AD user created, name: $username"
        }
    }
}

function isAdUserExisting {
    param (
        $identity
    )

    try {
        $user = Get-AdUser -Identity $identity
    }
    catch {
        $user
    }
    if ($user) {
       return [int]1
    }
    return [int]0
}

createAdStudent