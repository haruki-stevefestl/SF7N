function Invoke-ChangeRow {
    param (
        [ValidateSet('InsertBelow', 'InsertAbove', 'InsertLast', 'RemoveAt')]
        [String] $Action,
        [Int] $At,
        [Int] $Count
    )
}

function Export-CustomCSV ($ExportTo) {
    Write-Log 'INF' 'Export CSV'
    try {
        $wpf.CSVGrid.ItemsSource | Export-CSV $ExportTo -NoTypeInformation
    } catch {Write-Log 'ERR' 'Export CSV Failed'}

    Import-CSV $ExportTo
}