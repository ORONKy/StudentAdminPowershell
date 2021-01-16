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

    "$(Get-Date -f g) [$type] $Message" | Out-File -FilePath $GlobalLogPath"\LogFile.log" -Append
}