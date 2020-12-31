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
        if (!$getDbStudent) {
            if ($student.status -eq 1) {
                $studentFirstname = ($student.vorname).replace("'", "\'")
                $studentName = ($student.name).replace("'", "\'")
                $addquerry = "INSERT INTO schueler(username, id, name, vorname, geburtsdatum, kuerzel, mail) VALUES ('$($student.username)', '$($student.id)', '$($studentName)', '$($studentFirstname)','$($student.geburtsdatum)', '$($student.kuerzel)', '$($student.mail)')"
                runSql $database $addquerry
                log "Student addet to db id: $($student.id)" "INFO"
                $studentDBid = runSql $database "SELECT LAST_INSERT_ID()"

                $mainclass = $student.profile.profil.stammklasse
                if($mainclass){
                    addClass $studentDBid $mainclass
                }

                $secondclass = $student.profile.profil.zweitausbildung_stammklasse
                if($secondclass){
                    addClass $studentDBid $secondclass
                }
            }
    }
}
}

function addClass {
    param (
        $studentDBid,
        [string]$classname
    )
    if($classname){
        try {
            $querr ="select * from klasse where klassenbezeichnung = '$($classname)'"
            $class = runSql $database $querr
        }
        catch {
            $class
        }
        if (!$class) {
            runSql $database "INSERT INTO klasse(klassenbezeichnung) VALUES ('$($classname)')"
            log "new class created name: $($classname)" "INFO"
            $classDBid = runSql $database "SELECT LAST_INSERT_ID()"
        }
        else {
            $classDBid = $class[0]
        }
        runSql $database "INSERT INTO ``schueler-klasse``(sid, kid) VALUES ('$($studentDBid[0])', '$($classDBid[0])')"
        log "student addet to class, student: $studentDBid, class: $classDBid"
    }
    
}

$scoolData = readXmlGetStudent
importSchuelerToDB $scoolData "m122projekt"