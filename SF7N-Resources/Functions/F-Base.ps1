function Write-Log ($Type, $Content) {
    if ($Type -eq 'ERR') {
        [Windows.MessageBox]::Show($Content, 'SF7N Interface', 'OK', 'Error') | Out-Null
    }
    Write-Host "[$(Get-Date -Format HH:mm:ss.fff)][$Type] $Content" | Out-Host
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
        $script:csvHeader = (Get-Content $ImportFrom -First 1) -replace '"','' -split ','
        [Collections.ArrayList] $script:csv = Import-CSV $ImportFrom
        
        $AliasLocation = '.\Configurations\CSVAlias.csv'
        if (Test-Path $AliasLocation) {
            [Collections.ArrayList] $script:csvAlias = Import-CSV $AliasLocation
        }
    
    } catch {Write-Log 'ERR' "Import CSV Failed: $_"}
}

function New-SaveDialog {
    [Windows.MessageBox]::Show('Commit unsaved changes before exiting?', 'SF7N Interface', 3)
}
