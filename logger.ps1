. .\GlobalVariables.ps1

enum enumLogTypes {
    information = "INFO"
    warning = "WARN"
    error = "ERROR"

}
function log {
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('INFO','WARN','ERROR')]
        [string]$type
    )
    [logdata]@{
        Time = (Get-Date -f g)
        Type = $type
        Message = $Message
    } | Export-Csv -Path "$logPath\LogFile.csv" -Append -NoTypeInformation
}