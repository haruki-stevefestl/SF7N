function Import-CustomCSV ($ImportFrom) {
    # Creates following variables:
    #   - csv        [AList] Content
    #   - csvHeader  [Array] Header of the CSV
    #   - csvAlias   [Array] Aliases for CSV
    Write-Log 'Import CSV'
    $ImportFrom = Expand-Path $ImportFrom
    [Collections.ArrayList] $script:csv = Import-CSV $ImportFrom

    $Reader = [IO.StreamReader]::New($ImportFrom)
    $script:csvHeader = $Reader.ReadLine() -replace '"' -split ','

    $Alias = '.\Configurations\CSVAlias.csv'
    if (Test-Path $Alias) {$script:csvAlias = Import-CSV $Alias}

    if (!$csvHeader) {throw 'Data file is empty'}
}

function Export-CustomCSV ($ExportTo) {
    try {
        $csv | Export-CSV (Expand-Path $ExportTo) -NoTypeInformation
        $wpf.Commit.IsEnabled = $false
    } catch {
        throw ('CSV cannot be saved: '+$_)
    }
}
