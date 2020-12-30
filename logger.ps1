. .\GlobalVariables.ps1

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

    [pscustomobject]@{
        Time = (Get-Date -f g)
        Type = $type
        Message = $Message
    } | Export-Csv -Path $GlobalLogPath"\LogFile.csv" -Append
}
log "test log" "INFO"
