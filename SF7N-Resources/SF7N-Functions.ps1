#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Update-GUI {
    $wpf.SF7N.Dispatcher.Invoke("Render",[action][scriptblock]{})
}

function Show-MessageBox {
    param (
        [Parameter(Mandatory=$true)][String] $Prompt,
        [Parameter(Mandatory=$true)][String] $Button,
        [Parameter(Mandatory=$true)][String] $Image
    )
    return [System.Windows.MessageBox]::Show($Prompt,'SF7N Interface',$Button)
}

function Write-Log {
    param (
        [ValidateSet('INF','DBG','ERR')][String] $Type,
        [String] $Content
    )

    # Create/append to $log variable
    if ($null -eq $log) {[System.Collections.ArrayList] $script:log = @()}
    $script:log.Add([PSCustomObject] @{
        Time = Get-Date -Format 'HH:mm:ss.fff'
        Type = $Type
        Log  = $Content
    }) | Out-Null

    if ($Type -eq 'ERR') {Show-MessageBox $Content 'OK' 'Error'}

    # Actual outputt
    Write-Host "[$($script:log[-1].Time)][$Type] $Content" | Out-Host
    if ($null -ne $wpf.uiLog) {$wpf.uiLog.Text = $script:log | Format-Table * | Out-String}
}

function Import-CustomCSV ($ImportFrom) {
    <#
        Creates following variables:
        - csvHeader    [Array] Header of the CSV
        - csvRaw       [AList] String content from CSV
        - csv          [AList] Actual datalogging content (line 9~)
        - csvAlias     [AList] Aliases stored in CSV (line 1~8)
        - csvSearch    [AList] Matching results in searching
    #>
    Write-Log 'INF' 'Import CSV'
    try {
        [Array] $script:csvHeader = ((Get-Content $ImportFrom -First 1) -replace '"','') -split ','
        [System.Collections.ArrayList] $script:csvRaw    = [System.IO.File]::ReadAllText($ImportFrom) | ConvertFrom-CSV
        [System.Collections.ArrayList] $script:csv       = $csvRaw[8..$csvRaw.Count]
        [System.Collections.ArrayList] $script:csvAlias  = $csvRaw[0..7]
        [System.Collections.ArrayList] $script:csvSearch = @()

        $wpf.CSVGrid.ItemsSource = $csv
    } catch {Write-Log 'ERR' "Import CSV Failed: $_"}
}

function Set-Preview ($InputObject) {
    # Set preview image of illustration
    $InputObject = "S:\PNG\$InputObject.png"
    if (Test-Path $InputObject) {$wpf.Preview.Source = $InputObject}

    # Update Active Cell
    $wpf.ActiveCell.Text =
        "Active Cell: (" +
        $wpf.CSVGrid.Items.Indexof($wpf.CSVGrid.SelectedCells[0].Item) +
        "," +
        $wpf.CSVGrid.SelectedCells[0].Column.DisplayIndex +
        ") ~ (" +
        $wpf.CSVGrid.Items.Indexof($wpf.CSVGrid.SelectedCells[-1].Item) +
        "," +
        $wpf.CSVGrid.SelectedCells[-1].Column.DisplayIndex +
        ")"
}

function Import-Configuration {
    Write-Log 'INF' 'Import Configuration'
    try {
        # Retrieve configurations from .ini
        $script:configuration = Get-Content "$PSScriptRoot\SF7N-Configuration.ini" |
            Select-Object -Skip 1 |
                ConvertFrom-StringData

        # Apply them
        $wpf.AliasMode.IsChecked   = $configuration.AliasMode   -eq 'true'
        $wpf.InputAssist.IsChecked = $configuration.InputAssist -eq 'true'
        $wpf.InsertLastCount.Text  = $configuration.InsertLastCount
    } catch {Write-Log 'ERR' "Import Configuration Failed: $_"}
}

function Export-Configuration {
    Write-Log 'INF' 'Export Configuration'
    try {
        # Retrieve modifiable configurations from UI
        $configuration.AliasMode       = $wpf.AliasMode.IsChecked
        $configuration.InputAssist     = $wpf.InputAssist.IsChecked
        $configuration.InsertLastCount = $wpf.InsertLastCount.Text

        # Export them
        '[SF7N-Configuration]' | Set-Content "$PSScriptRoot\SF7N-Configuration.ini"
        $configuration.GetEnumerator().ForEach({
            "$($_.Keys)=$($_.Values)" |
                Add-Content "$PSScriptRoot\SF7N-Configuration.ini"
        })
    } catch {Write-Log 'ERR' "Exoprt Configuration Failed: $_"}
}
