. .\readXml.ps1
. .\MySQL.ps1

function importSchuelerToDB {
    param (
        [xml]$xmlList,
        [string]$database
    )
    $students = $xmlList.ad.schueler

    foreach ($student in $students) {
        $querry = "select * from schueler WHERE id = " + $student.id + ";"

        try {
            $getDbStudent = runSql $database $querry
            return
        }
        catch {
            $getDbStudent
        }
        if (!$getDbStudent -and $student.status -eq 1) {
            $addquerry = "INSERT INTO schueler(username, id, name, vorname, geburtsdatum, kuerzel, mail) VALUES ('$($student.username)', '$($student.id)', '$($student.name)', '$($student.vorname)','$($student.geburtsdatum)', '$($student.kuerzel)', '$($student.mail)')"
            #TODO need logger
            runSql $database $addquerry
            $student.profile.profile
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