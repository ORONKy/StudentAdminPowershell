Write-Host "[INFO]: das Powershell skript muss mit adminrechten ausgeführ werden"

. .\ImportSchuelerToDB.ps1
. .\ImportTeacherToDb.ps1
. .\CreateAdGroups.ps1
. .\CreateStudentAdAcouts.ps1
. .\ManageAd.ps1