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
                $studentDBid
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
                        log "New Class created name: "$mainclass "INFO"
                        $classDBid = runSql $database "SELECT LAST_INSERT_ID()"
                    }
                    else {
                        $classDBid = $class[0]
                    }
                    runSql $database "INSERT INTO ``schueler-klasse``(sid, kid) VALUES ('$($studentDBid[0])', '$($classDBid[0])')"
                    log "student added to class, student: "$studentDBid[0]", class: $classDBid[0]"
            }
            $secondclass = $student.profile.profil.zweitausbildung_stammklasse
            if($secondclass){
                try {
                    $secclass = runSql $database "select * from klasse where klassenbezeichnung = $($secondclass)"
                }
                catch {
                    $secclass
                }
                if (!$class) {
                    runSql $database "INSERT INTO klasse(klassenbezeichnung) VALUES ('$($mainclass)')"
                    $classDBid = runSql $database "SELECT LAST_INSERT_ID()"
                }
                else {
                    $classDBid = $secclass[0]
                }
                runSql $database "INSERT INTO ``schueler-klasse``(sid, kid) VALUES ('$($studentDBid[0])', '$($classDBid[0])')"
            }
            }
    }
}
}

function addClassAndGetId {
    param (
        [int]$studentDBid,
        [string]$classname
    )
    if($classname){
        try {
            $class = runSql $database "select * from klasse where klassenbezeichnung = $($classname)"
        }
        catch {
            $class
        }
        if (!$class) {
            runSql $database "INSERT INTO klasse(klassenbezeichnung) VALUES ('$($classname)')"
            $classDBid = runSql $database "SELECT LAST_INSERT_ID()"
        }
        else {
            $classDBid = $class[0]
        }
        runSql $database "INSERT INTO ``schueler-klasse``(sid, kid) VALUES ('$($studentDBid[0])', '$($classDBid[0])')"
    }
    
}

$scoolData = readXmlGetStudent
importSchuelerToDB $scoolData "m122projekt"