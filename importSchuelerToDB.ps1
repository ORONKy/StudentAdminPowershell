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
        }
        catch {
            $getDbStudent
        }
        if (!$getDbStudent) {
            $addquerry = "INSERT INTO schueler username, id, name, vorname, geburtsdatum, kurzel, mail 
            VALUES " + $student.username +","+$student.id+","+$student.name+","+$student.vorname+","+$student.kuerzel+","+$student.mail+";"
            
            runSql $database $addquerry
        }
    }
}

$scoolData = readXmlGetStudent
importSchuelerToDB $scoolData "m122projekt"