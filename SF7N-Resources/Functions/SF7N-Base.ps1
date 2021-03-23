#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Write-Log {
    param (
        [ValidateSet('INF','DBG','ERR')][String] $Type,
        [String] $Content
    )

    if ($Type -eq 'ERR') {
        [Windows.MessageBox]::Show($Content, 'SF7N Interface', 'OK', 'Error') | Out-Null
    }

    # Output log to Host and Progressbar
    Write-Host "[$(Get-Date -Format 'HH:mm:ss.fff')][$Type] $Content" | Out-Host
    if ($null -ne $wpf.LoadingText) {$wpf.LoadingText.Text = $Content}
}

function Import-CustomCSV ($ImportFrom) {
    <#
        Creates following variables:
        - csvSearch    [AList] Matching results in searching
        - csvHeader    [Array] Header of the CSV
        - csv          [AList] Content from CSV
        - csvAlias     [AList] Aliases for CSV
    #>
    Write-Log 'INF' 'Import CSV'
    try {
        [Collections.ArrayList] $script:csvSearch = @()
        $script:csvHeader = (Get-Content $ImportFrom -First 1) -replace '"','' -split ','
        [Collections.ArrayList] $script:csv = [IO.File]::ReadAllText($ImportFrom) | ConvertFrom-CSV
        
        $AliasLocation = "$baseLocation\Configurations\CSVAlias.csv"
        if (Test-Path $AliasLocation) {
            [Collections.ArrayList] $script:csvAlias = Get-Content $AliasLocation | ConvertFrom-CSV
        }
    
    } catch {Write-Log 'ERR' "Import CSV Failed: $_"}
}

function Import-Configuration ($ImportFrom) {
    Write-Log 'INF' "Import Configuration - $(($ImportFrom -Split '-')[-1])"
    try {
        return Get-Content $ImportFrom | Select-Object -Skip 1 | ConvertFrom-StringData
    } catch {Write-Log 'ERR' "Import Configuration Failed: $_"}
}
