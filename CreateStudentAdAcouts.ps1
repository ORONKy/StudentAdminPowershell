. .\GlobalVariables.ps1
. .\MySQL.ps1
. .\Logger.ps1

function createAdStudent {
    param (
        
    )

    $students = runSql $GlobalDatabaseName "SELECT * FROM schueler"
    foreach($student in $students){
        $username = $student[1]
        [bool]$wthf = isAdUserExisting $username
        $wthf.class
        if (-Not $wthf) {
            $password = ConvertTo-SecureString  $GlobalFirstStudentPassword
            New-ADUser -Name $username -AccountPassword $password -Path $GlobalStudentOUPath -DisplayName $username
            log "New AD user created, name: $username"
        }
    }
}

function isAdUserExisting {
    param (
        $identity
    )

    [bool]$tru = 1
    [bool]$fls = 0

    try {
        $user = Get-AdUser -Identity $identity
    }
    catch {
        $user
    }
    if ($user) {
       return [bool]$fls
    }
    return [bool]$true
}

createAdStudent