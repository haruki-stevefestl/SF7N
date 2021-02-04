#—————————————————————————————————————————————————————————————————————————————+—————————————————————
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

    # Actual output
    Write-Host "[$($script:log[-1].Time)][$Type] $Content" | Out-Host
    if ($null -ne $wpf.uiLog) {$wpf.uiLog.Text = $script:log | Format-Table * | Out-String}
}

function Import-CustomCSV ($ImportFrom) {
    <#
        Creates following variables:
        - csvHeader    [Array] Header of the CSV
        - csv          [AList] Content from CSV
        - csvAlias     [AList] Aliases for CSV
        - csvSearch    [AList] Matching results in searching
    #>
    Write-Log 'INF' 'Import CSV'
    try {
        [Array] $script:csvHeader = ((Get-Content $ImportFrom -First 1) -replace '"','') -split ','
        [System.Collections.ArrayList] $script:csv       = [System.IO.File]::ReadAllText($ImportFrom) | ConvertFrom-CSV
        [System.Collections.ArrayList] $script:csvAlias  = Get-Content "$baseLocation\Configurations\CSVAlias.csv" | ConvertFrom-CSV
        [System.Collections.ArrayList] $script:csvSearch = @()
    } catch {Write-Log 'ERR' "Import CSV Failed: $_"}
}

function Import-Configuration ($ImportFrom) {
    Write-Log 'INF' 'Import Configuration'
    try {
        # Retrieve configurations from .ini
        $script:configuration = Get-Content $ImportFrom |
            Select-Object -Skip 1 |
                ConvertFrom-StringData

        # Apply them
        $wpf.AliasMode.IsChecked   = $configuration.AliasMode   -eq 'true'
        $wpf.InputAssist.IsChecked = $configuration.InputAssist -eq 'true'
        $wpf.InsertLastCount.Text  = $configuration.InsertLastCount
    } catch {Write-Log 'ERR' "Import Configuration Failed: $_"}
}

function Export-Configuration ($ExportTo) {
    Write-Log 'INF' 'Export Configuration'
    try {
        # Retrieve modifiable configurations from UI
        $configuration.AliasMode       = $wpf.AliasMode.IsChecked
        $configuration.InputAssist     = $wpf.InputAssist.IsChecked
        $configuration.InsertLastCount = $wpf.InsertLastCount.Text

        # Export them
        '[SF7N-Configuration]' | Set-Content "$ExportTo"
        $configuration.GetEnumerator().ForEach({
            "$($_.Keys)=$($_.Values)" |
                Add-Content "$ExportTo"
        })
    } catch {Write-Log 'ERR' "Export Configuration Failed: $_"}
}
