#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Export-CustomCSV ($ExportTo) {
    try {
        $csv | Export-CSV $ExportTo -NoTypeInformation
    } catch {Write-Log 'Export CSV Failed'}
}

function Invoke-ChangeRow {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('InsertAbove','InsertBelow','InsertLast','Remove')]
        [String] $Action,
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

        $At = $wpf.CSVGrid.Items.IndexOf($wpf.CSVGrid.SelectedCells[0].Item)
        $Count = $wpf.CSVGrid.SelectedCells.Count

        # Log in the correct format
        if ($Action -eq 'InsertLast') {
            $Count = $wpf.InsertLastCount.Text
            # Get last character of last entry's leftmost item
            [String] $IDStart = $csv[-1].($csvHeader[0])[-1]

            # if IDStart is integer, add one; else set to zero
            if ($IDStart -match '^\d+?$') {
                ++ [Int] $IDStart
            } else {
                [Int] $IDStart = 0
            }

            Write-Log 'INF' "Change Rows: InsertLast for $Count rows"
        } else {
            if ($Action -eq 'InsertBelow') {$At += $Count}
            Write-Log 'INF' "Change Rows: $Action at $At for $Count rows"
        }

        for ($I = $IDStart; $I -lt $ID+$Count; $I++) {
            if ($Action -eq 'InsertLast') {
                # Add $Count rows at end with IDing
                $ThisRow = $RowTemplate.PsObject.Copy()
                $ThisRow.($csvHeader[0]) = "$(Get-Date -Format yyyyMMdd)-$I"
                $script:csv.Add($ThisRow)
            } else {
                # Max & Min functions to prevent under/overflowing
                $script:csv.Insert([Math]::Max(0,[Math]::Min($At,$csv.Count)), $RowTemplate)
            }
        }

    } else {
        Write-Log 'INF' "Change Rows: $Action selected rows"
        @($wpf.CSVGrid.SelectedCells).ForEach{$script:csv.Remove($_.Item)}
    }

    $wpf.CSVGrid.Items.Refresh()
}
