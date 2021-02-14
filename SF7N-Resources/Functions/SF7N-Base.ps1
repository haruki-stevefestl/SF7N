#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Write-Log {
    param (
        [ValidateSet('INF','DBG','ERR')][String] $Type,
        [String] $Content
    )

    if ($Type -eq 'ERR') {
        [System.Windows.MessageBox]::Show($Content, 'SF7N Interface', 'OK', 'Error') | Out-Null
    }

    # Output log to Host and Progressbar
    Write-Host "[$(Get-Date -Format 'HH:mm:ss.fff')][$Type] $Content" | Out-Host
    if ($null -ne $wpf.LoadingText) {$wpf.LoadingText.Text = $Content}
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
        $script:csvHeader = ((Get-Content $ImportFrom -First 1) -replace '"','') -split ','
        [System.Collections.ArrayList] $script:csv       = [System.IO.File]::ReadAllText($ImportFrom) | ConvertFrom-CSV
        [System.Collections.ArrayList] $script:csvAlias  = Get-Content "$baseLocation\Configurations\CSVAlias.csv" | ConvertFrom-CSV
        [System.Collections.ArrayList] $script:csvSearch = @()
    } catch {Write-Log 'ERR' "Import CSV Failed: $_"}
}

function Import-Configuration ($ImportFrom) {
    Write-Log 'INF' "Import Configuration - $(Split-Path $ImportFrom -Leaf)"
    try {
        return Get-Content $ImportFrom | Select-Object -Skip 1 | ConvertFrom-StringData
    } catch {Write-Log 'ERR' "Import Configuration Failed: $_"}
}
