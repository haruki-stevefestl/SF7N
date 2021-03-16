#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Export-CustomCSV ($ExportTo) {
    try {
        $csv | Export-CSV $ExportTo -NoTypeInformation
        $wpf.SF7N.Title = 'SF7N Interface'
    } catch {Write-Log 'ERR' "Export CSV Failed: $_"}
}

function Add-Row {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('InsertAbove','InsertBelow','InsertLast')]
        [String] $Action
    )

    # Make editor dirty
    $wpf.SF7N.Title = 'SF7N Interface  (Changes Unsaved)'

    # Prepare blank template for inserting
    $RowTemplate = [PSCustomObject] @{}
    $csvHeader.foreach{$RowTemplate | Add-Member NoteProperty $_ ''}

    # Execute preparations for each type of insert
    $At = $wpf.CSVGrid.Items.IndexOf($wpf.CSVGrid.SelectedCells[0].Item)
    $LastIndex = 0

    if ($Action -eq 'InsertLast') {
        # Scroll bottom into view
        $wpf.CSVGrid.ScrollIntoView($wpf.CSVGrid.Items[-1], $wpf.CSVGrid.Columns[0])
        $Count = $wpf.InsertLastCount.Text

        # Get starting index
        # If there already are entries, add 1 to the starting index; else 0
        # e.g. If 20200409 = Today --> Index += 1 else Index = 0
        $LastIndex = $csv[-1].($csvHeader[0])
        if ($LastIndex.Split('-')[0] -eq (Get-Date -Format yyyyMMdd)) {
            $LastIndex = [Int] ($LastIndex.Split('-')[1]) + 1
        } else {
            $LastIndex = 0
        }

    } else {
        $Count = $wpf.CSVGrid.SelectedCells.Count

        # $At += $Count doesn't work somehow
        if ($Action -eq 'InsertBelow') {$At = $At + $Count} 
    }

    Write-Log 'INF' "Change Rows: $Action at $At for $Count rows"
    for ($I = $LastIndex; $I -lt ($LastIndex+$Count); $I++) {
        if ($Action -eq 'InsertLast') {
            # Add rows at end with IDing
            $ThisRow = $RowTemplate.PsObject.Copy()
            $ThisRow.($csvHeader[0]) = "$(Get-Date -Format yyyyMMdd)-$I"
            $script:csv.Add($ThisRow)

        } else {
            # Max & Min functions to prevent under/overflowing
            $script:csv.Insert(
                [Math]::Max(0,[Math]::Min($At,$script:csv.Count)), $RowTemplate)
        }
    }

    $wpf.CSVGrid.ItemsSource = $script:csv
    $wpf.CSVGrid.Items.Refresh()
    Update-GUI
}
