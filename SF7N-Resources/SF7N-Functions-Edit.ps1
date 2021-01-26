#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Export-CustomCSV ($ExportTo) {
    try {
        $wpf.CSVGrid.Items | Export-CSV $ExportTo -NoTypeInformation
    } catch {Write-Log 'Export CSV Failed'}
}

function Invoke-ChangeRow {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('InsertAbove','InsertBelow','InsertLast','RemoveAt')]
        [String] $Action,

        [Parameter(Mandatory=$true)][Int] $At,
        [Parameter(Mandatory=$true)][Int] $Count
    )
}
