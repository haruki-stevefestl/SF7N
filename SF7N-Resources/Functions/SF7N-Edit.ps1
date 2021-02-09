#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Export-CustomCSV ($ExportTo) {
    try {
        $csv | Export-CSV $ExportTo -NoTypeInformation
    } catch {Write-Log 'ERR' 'Export CSV Failed'}
}

function Invoke-ChangeRow {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('InsertAbove','InsertBelow','InsertLast')]
        [String] $Action
    )

    # Prepare blank template for inserting
    $SCRIPT:RowTemplate = [PSCustomObject] @{}
    $script:csvHeader.foreach{$RowTemplate | Add-Member NoteProperty $_ ''}

    $SCRIPT:At = $wpf.CSVGrid.Items.IndexOf($wpf.CSVGrid.SelectedCells[0].Item)

    # Log in the correct format
    # if ($Action -eq 'InsertLast') {
    #     $SCRIPT:Count = $wpf.InsertLastCount.Text
        # Get index of last entry's leftmost item
        # e.g. 12345678-9 -> 9
        # [String] $SCRIPT:IDStart = $csv[-1].($csvHeader[0]).Split('-')[1]

        # if IDStart is integer, add one; else set to zero
        # if ($SCRIPT:IDStart -match '^\d+?$') {
        #     ++ [Int] $SCRIPT:IDStart
        # } else {
        #     [Int] $SCRIPT:IDStart = 0
        # }

        # Write-Log 'INF' "Change Rows: InsertLast for $Count rows"
    # } else {
        $SCRIPT:Count = $wpf.CSVGrid.SelectedCells.Count
        if ($Action -eq 'InsertBelow') {$At = $At + $Count} # $At += $Count doesn't work
        Write-Log 'INF' "Change Rows: $Action at $At for $Count rows"
    # }

    write-log 'DBG' "$Action"
    for ($I = 0; $I -lt $Count; $I++) {
        write-log 'DBG' "$Action" | out-host
        # if ($Action -eq 'InsertLast') {
            # Add $Count rows at end with IDing
            # $ThisRow = $RowTemplate.PsObject.Copy()
            # $ThisRow.($csvHeader[0]) = "$(Get-Date -Format yyyyMMdd)-$I"
            # $script:csv.Add($ThisRow)
            # $script:csv.Add($RowTemplate)
        # } else {
            # Max & Min functions to prevent under/overflowing
            $script:csv.Insert([Math]::Max(0,[Math]::Min($At,$script:csv.Count)), $RowTemplate)
        # }
    }

    $wpf.CSVGrid.ItemsSource = $script:csv
    $wpf.CSVGrid.Items.Refresh()
    Update-GUI
}
