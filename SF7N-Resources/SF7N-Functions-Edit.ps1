#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Export-CustomCSV ($ExportTo) {
    try {
        $csvRaw | Export-CSV $ExportTo -NoTypeInformation
    } catch {Write-Log 'Export CSV Failed'}
}

function Invoke-ChangeRow {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('InsertAbove','InsertBelow','InsertLast','Remove')]
        [String] $Action,

        [Parameter(Mandatory=$false)][Int] $At,
        [Parameter(Mandatory=$false)][Int] $Count,
        [Parameter(Mandatory=$false)][Int] $IDStart
    )

    <#
        Major Logic Flow
        If Insert?
            - InsertLast
            - InsertAbove/Below
        Else
            - Remove
    #>

    if ($Action -match 'Insert') {
        # Prepare blank template for inserting
        $RowTemplate = [PSCustomObject] @{}
        $script:csvHeader.foreach{$RowTemplate | Add-Member NoteProperty $_ ''}

        # Log in the correct format
        if ($Action -eq 'InsertLast') {
            Write-Log 'INF' "Change Rows: InsertLast for $Count rows"
        } else {
            if ($Action -eq 'InsertBelow') {$At += $Count}
            Write-Log 'INF' "Change Rows: $Action at $At for $Count rows"
        }

        for ($I = $IDStart; $I -lt $ID+$Count; $I++) {
            if ($Action -eq 'InsertLast') {
                # Add $Count rows at end with IDing
                $ThisRow = $RowTemplate.PsObject.Copy()
                $ThisRow.ID = "$(Get-Date -Format yyyyMMdd)-$I"
                $script:csvRaw.Add($ThisRow)
            } else {
                # Max & Min functions to prevent under/overflowing
                $script:csvRaw.Insert([Math]::Max(0,[Math]::Min($At,$csvRaw.Count)), $RowTemplate)
            }
        }

    } else {
        Write-Log 'INF' "Change Rows: $Action selected rows"
        @($wpf.CSVGrid.SelectedCells).ForEach{$script:csvRaw.Remove($_.Item)}
    }

    $wpf.CSVGrid.Items.Refresh()
}
