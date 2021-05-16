function Export-CustomCSV ($ExportTo) {
    try {
        $csv | Export-CSV $ExportTo -NoTypeInformation
        $wpf.SF7N.Title = 'SF7N Interface'
        $wpf.Commit.IsEnabled = $false
    } catch {Write-Log 'ERR' "Export CSV Failed: $_"}
}

function Add-Row ($Action) {
    # Prepare blank template for inserting
    $RowTemplate = [PSCustomObject] @{}
    $csvHeader.Foreach{$RowTemplate | Add-Member NoteProperty $_ ''}

    # Execute preparations for each type of insert
    $At = $wpf.CSVGrid.Items.IndexOf($wpf.CSVGrid.SelectedItems[0])
    $Count = $wpf.CSVGrid.SelectedItems.Count

    if ($Action -eq 'InsertLast') {
        $Count = $wpf.InsertLastCount.Text
        $wpf.CSVGrid.ScrollIntoView($wpf.CSVGrid.Items[-1], $wpf.CSVGrid.Columns[0])
    
    } elseif ($Action -eq 'InsertBelow') {
        $At += $Count
    }

    if ($Action -eq 'InsertLast') {
        for ($I = 0; $I -lt $Count; $I++) {
            # Add rows at end with IDing
            $ThisRow = $RowTemplate.PsObject.Copy()
            $ThisRow.($csvHeader[0]) = $config.AppendFormat -replace
                '%D', (Get-Date -Format yyyyMMdd) -replace
                '%T', (Get-Date -Format HHmmss)   -replace
                '%#', $I
            if ($csv) {
                $csv.Add($ThisRow)
            } else {
                [Collections.ArrayList] $csv = @($ThisRow)
            }
        }
    } else {
        # Max & Min functions to prevent under/overflowing
        $csv.InsertRange([Math]::Max(0,[Math]::Min($At,$csv.Count)), @($RowTemplate) * $Count)
    }

    $wpf.CSVGrid.ItemsSource = $csv
    $wpf.CSVGrid.Items.Refresh()
}
