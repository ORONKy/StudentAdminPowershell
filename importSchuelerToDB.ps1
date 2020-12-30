. .\readXml.ps1
. .\MySQL.ps1
. .\Logger.ps1

function importSchuelerToDB {
    param (
        [xml]$xmlList,
        [string]$database
    )
    $students = $xmlList.ad.schueler

    foreach ($student in $students) {
        $querry = "select * from schueler WHERE id = ' $($student.id) ';"

        try {
            $getDbStudent = runSql $database $querry
        }
        catch {
            $getDbStudent
        }
        #test if working
        #else finish
        if (!$getDbStudent -and $student.status -eq 1) {
            $addquerry = "INSERT INTO schueler(username, id, name, vorname, geburtsdatum, kuerzel, mail) VALUES ('$($student.username)', '$($student.id)', '$($student.name)', '$($student.vorname)','$($student.geburtsdatum)', '$($student.kuerzel)', '$($student.mail)')"
            runSql $database $addquerry
            log "Student addet to db id: $($student.id)"
            $mainclass = $student.profile.profil.stammklasse
            if($mainclass){
                try {
                    $class = runSql $database "select * from klasse where klassenbezeichnung = $($mainclass)"
                }
                catch {
                    $class
                }
                if (!$class) {
                    $studentDBid = runSql $database "SELECT LAST_INSERT_ID()"
                    runSql $database "INSERT INTO klasse(klassenbezeichnung) VALUES ('$($mainclass)')"
                    $classDBid = runSql $database "SELECT LAST_INSERT_ID()"
                }
                else {
                    $classDBid = $class[0]
                }
                runSql $database "INSERT INTO ``schueler-klasse``(sid, kid) VALUES ('$($studentDBid[0])', '$($classDBid[0])')"
            }
        }
    }
}

function addClassAndGetId {
    param (
        [string]$database,
        [string]$class
    )
    $checkquerry = "SELECT * FROM klasse where "
    
}

$scoolData = readXmlGetStudent
importSchuelerToDB $scoolData "m122projekt"