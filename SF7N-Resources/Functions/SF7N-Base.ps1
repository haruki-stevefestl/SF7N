#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Write-Log ($Type, $Content) {
    if ($Type -eq 'ERR') {
        [Windows.MessageBox]::Show($Content, 'SF7N Interface', 'OK', 'Error') | Out-Null
    }
    Write-Host "[$(Get-Date -Format 'HH:mm:ss.fff')][$Type] $Content" | Out-Host
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
        
        $AliasLocation = "$PSScriptRoot\Configurations\CSVAlias.csv"
        if (Test-Path $AliasLocation) {
            [Collections.ArrayList] $script:csvAlias = Get-Content $AliasLocation | ConvertFrom-CSV
        }
    
    } catch {Write-Log 'ERR' "Import CSV Failed: $_"}
}
