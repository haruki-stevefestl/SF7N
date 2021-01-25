function Invoke-ChangeRow {
    param (
        [ValidateSet('InsertBelow', 'InsertAbove', 'InsertLast', 'RemoveAt')]
        [String] $Action,
        [Int] $At,
        [Int] $Count
    )
}

function Export-CustomCSV {
    Write-Log 'INF' 'Save  CSV'
    try {
        $wpf.CSVGrid.ItemsSource | Export-CSV $csvLocation -NoTypeInformation
    } catch {Write-Log 'ERR' 'Save  CSV Failed'}
}