. .\GlobalVariables.ps1
. .\MySQL.ps1
. .\Logger.ps1

function createAdStudent {
    param (
        
    )

    $students = runSql $GlobalDatabaseName "SELECT * FROM schueler"
    foreach($student in $students){
        $username = $student[1]
        if ($username.length -gt 20) {
            $username = $username.subString(0,20)
        }
        $wthf = isAdUserExisting $username
        if ($wthf[1] -eq 0) {
            $password = ConvertTo-SecureString $GlobalFirstStudentPassword -AsPlainText -Force
            try {
                New-ADUser -AccountPassword $password -Path $GlobalStudentOUPath -Name $username -Surname $student[3] -GivenName $student[4] -Enabled $true
            }
            catch {
                log "cant create AD User, username: $username, error $_" "ERROR"
            }
            
            log "New AD user created, name: $username" "INFO"
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