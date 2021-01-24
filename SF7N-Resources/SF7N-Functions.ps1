function Update-GUI {
    $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})
}

function Write-Log ($Location, $Type, $Message) {
    Write-Host "[$(Get-Date -Format HH:mm:ss.fff)][$Location][$Type][$Message]"
}

function Update-CSV ($ImportFrom) {
    [System.Collections.ArrayList] $global:csvRaw = [System.IO.File]::ReadAllText($csvLocation) | ConvertFrom-Csv
    $global:csv       = $csvRaw[8..$csvRaw.Count]
    $global:csvAlias  = $csvRaw[1..7]
    $global:csvHeader = $csvRaw[0]
}

function Search-CSV {}

function Invoke-ChangeRow {}

function Export-Configuration {}

function Import-Configuration {}

