. .\Logger.ps1
. .\MySQL.ps1
function clearDbTables
{
    param (
    )
    $tables = @("``lehrer-fach-klasse``","``schueler-klasse``", "lehrer", "fach", "klasse", "schueler")
    foreach($table in $tables){
        runSql $GlobalDatabaseName "DELETE FROM $table"
    }
    log "tables cleared, tables: $tables" "INFO"
}

clearDbTables

. .\ImportSchuelerToDB.ps1
. .\ImportTeacherToDb.ps1
. .\CreateAdGroups.ps1
Write-Host "Group Finished"
. .\CreateStudentAdAcouts.ps1
Write-Host "jojo"
. .\ManageAd.ps1
