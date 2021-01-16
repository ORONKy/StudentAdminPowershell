. .\GlobalVariables.ps1
. .\Logger.ps1
. .\ReadXml.ps1
. .\MySQL.ps1

function importTeacher {
    param (
        [xml]$xmlList
    )
    $teachers =$xmlList.ad.lehrer | Where-Object status -ne 0
    foreach($teacher in $teachers){
        
        if (!(isTeacherInDB $teacher.id) -and $teacher.status -eq 1) {
            $querry = "INSERT INTO lehrer(username, id, name , vorname, geburtsdatum, kuerzel, mail) VALUES('$($teacher.username)', '$($teacher.id)', '$($teacher.name)', '$($teacher.vorname)', '$($teacher.geburtsdatum)', '$($teacher.kuerzel)', '$($teacher.mail)')"
            runSql $GlobalDatabaseName $querry
            $teacherDBid = runSql $GlobalDatabaseName "SELECT LAST_INSERT_ID()"
            log "teacher added to db, id: $($teacher.id)" "INFO"
            $classes = $teacher.regelklassen.klasse
            $courses = $teacher.kurse.kurs
            classTeacherCoursAssign $classes $courses $teacherDBid[0]
        }
    }
}

function isTeacherInDB {
    param (
        [string]$teacherId
    )
    try {
        $teacher = runSql $GlobalDatabaseName "select * from lehrer where id = '$teacherId'"
    }
    catch {
        return $false
    }
    if ($teacher) {
        return $true
    }
   return $false

}

function classTeacherCoursAssign {
    param (
        $classes,
        $courses,
        $teacherDBid
    )
    foreach($cours in $courses){
        $coursShort = $cours.kurs_kuerzel
        [bool]$isCourseInClass = $false
        foreach($class in $classes){
            if($coursShort -match $class.klasse_kuerzel){
                $coursDBid = getCoursDBid $cours.kurs_bezeichnung
                $classDBid = getClassDBid $class.klasse_kuerzel
                $querry = "INSERT INTO ``lehrer-fach-klasse``(fid, kid, lid) VALUES ('$($coursDBid)', '$classDBid', '$teacherDBid')"
                runSql $GlobalDatabaseName $querry
                log "new cours_class_teacher_assign, coursid:$coursDBid, classid:$classDBid, teacherid:$teacherDBid" "INFO"
            }
           ##BREAK REMOVED
        }
        # if ($isCourseInClass) {
        #     $coursDBid = getCoursDBid $classDBid.kurs_bezeichnung
        #     $classDBid = getClassDBid $class.klasse_kuerzel
        #     $querry = "INSERT INTO ``lehrer-fach-klasse``(fid, kid, lid) VALUES ('$($coursDBid)', '$classDBid', '$teacherDBid')"
        #     if (!(isAssigne $coursDBid, $classDBid, $teacherDBid)) {
        #         runSql $GlobalDatabaseName $querry
        #         log "new cours_class_teacher_assign, coursid:$coursDBid, classid:$classDBid, teacherid:$teacherDBid" "INFO"

        #     }
        # }
    }
}

function getClassDBid {
    param (
        [string]$classShort
    )
    try {
        $class = runSql $GlobalDatabaseName "select * from klasse where klassenbezeichnung = '$classShort' "
    }
    catch {
        $class
    }
    if (!$class) {
        runSql $GlobalDatabaseName "INSERT INTO klasse(klassenbezeichnung) VALUES('$classShort')"
        log "Class added, classname:$classShort" "INFO"
        $classDBid = runSql $GlobalDatabaseName "SELECT LAST_INSERT_ID()"
    }else {
        $classDBid = $class[0]
    }
    return $classDBid[0]
}

function getCoursDBid {
    param (
        [string]$coursShort
    )
    try {
        $querry = "select * from fach where fachbezeichnung = '$coursShort'"
        $cours = runSql $GlobalDatabaseName $querry
    }
    catch {
        $cours
    }
    if (!$cours) {
        runSql $GlobalDatabaseName "INSERT INTO fach(fachbezeichnung) VALUES('$coursShort')"
        log "Cours added, coursname:$coursShort" "INFO"
        $coursDBid = runSql $GlobalDatabaseName "SELECT LAST_INSERT_ID()"
    }else {
        $coursDBid = $cours[0]
    }
    return $coursDBid[0]
}

function clearTable {
    param (
    )
    $tables = @("``lehrer-fach-klasse``","``schueler-klasse``", "lehrer", "fach", "klasse", "schuler")
    foreach($table in $tables){
        runSql $GlobalDatabaseName "DELETE FROM $table"
    }
    log "tables cleared, tables: $tables" "INFO"
}
$xml = readXml

importTeacher $xml
