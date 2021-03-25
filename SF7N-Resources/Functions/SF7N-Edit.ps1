#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Export-CustomCSV ($ExportTo) {
    try {
        $csv | Export-CSV $ExportTo -NoTypeInformation
        $wpf.SF7N.Title = 'SF7N Interface'
        $wpf.Commit.IsEnabled = $false
    } catch {Write-Log 'ERR' "Export CSV Failed: $_"}
}

function Add-Row ($Action) {
    # Make editor dirty
    $wpf.Commit.IsEnabled = $true

    # Prepare blank template for inserting
    $RowTemplate = [PSCustomObject] @{}
    $csvHeader.foreach{$RowTemplate | Add-Member NoteProperty $_ ''}

    # Execute preparations for each type of insert
    $At = $wpf.CSVGrid.Items.IndexOf($wpf.CSVGrid.SelectedCells[0].Item)
    $Count = $wpf.CSVGrid.SelectedCells.Count

    if ($Action -eq 'InsertLast') {
        $Count = $wpf.InsertLastCount.Text
        $wpf.CSVGrid.ScrollIntoView($wpf.CSVGrid.Items[-1], $wpf.CSVGrid.Columns[0])
    
    } elseif ($Action -eq 'InsertBelow') {
        $At += $Count
    }

    Write-Log 'INF' "Edit   CSV: $Action at $At for $Count rows"
    for ($I = 0; $I -lt $Count; $I++) {
        if ($Action -eq 'InsertLast') {
            # Add rows at end with IDing
            $ThisRow = $RowTemplate.PsObject.Copy()
            $ThisRow.($csvHeader[0]) = $config.AppendFormat -replace
                '%D', (Get-Date).ToString('yyyyMMdd') -replace
                '%T', (Get-Date).ToString('HHmmss')   -replace
                '%#', $I
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
