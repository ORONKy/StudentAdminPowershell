. .\MySQL.ps1

$test2 = runSql "m122projekt" "INSERT INTO klasse(klassenbezeichnung) VALUES ('ficki')"
$test = runSql "m122projekt" "select * from schueler where sid = 700"
$test[2]
"who" + $test2