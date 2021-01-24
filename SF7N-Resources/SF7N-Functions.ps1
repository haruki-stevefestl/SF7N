function Update-GUI {
    $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})
}

function Write-Log ($Location, $Type, $Message) {
    Write-Host "[$(Get-Date -Format HH:mm:ss.fff)][$Location][$Type][$Message]"
}

function Update-CSV ($ImportFrom) {
    [System.Collections.ArrayList] $global:csvRaw    = [System.IO.File]::ReadAllText($csvLocation) | ConvertFrom-Csv
    [System.Collections.ArrayList] $global:csv       = $csvRaw[8..$csvRaw.Count]
    [System.Collections.ArrayList] $global:csvAlias  = $csvRaw[1..7]
    $global:csvHeader = (Get-Content $csvLocation -First 1) -replace '"','' -split ','
    [System.Collections.ArrayList] $global:csvSearch = @()
}

function Search-CSV {
    # $global:csvSearch = $null
    $global:csvSearch = @()
    $wpf.CSVGrid.ItemsSource = $null
    
    $csv.ForEach({
        if ((Get-Random -Minimum 0 -Maximum 49) -eq 1) {
            $global:csvSearch.Add($_)
        }
    })

    $wpf.CSVGrid.ItemsSource = $csvSearch
}

function Invoke-ChangeRow {}

function Export-Configuration {}

function Import-Configuration {}

