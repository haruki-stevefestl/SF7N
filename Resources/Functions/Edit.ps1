function Add-Row ($Action) {
    # Prepare blank template for inserting
    $RowTemplate = [PSCustomObject] @{}
    $csvHeader.Foreach({$RowTemplate | Add-Member NoteProperty $_ ''})
    
    if ($Action -eq 'InsertLast') {
        for ($i = 0; $i -lt $context.AppendCount; $i++) {
            # Expand %x (legacy) and <x> (current) noation
            $ThisRow = $RowTemplate.PsObject.Copy()
            $ThisRow.($csvHeader[0]) = $context.AppendFormat -replace
                '%D|<D>', (Get-Date -Format yyyyMMdd) -replace
                '%T|<T>', (Get-Date -Format HHmmss)   -replace
                '%#|<#>', $I
            if ($csv) {
                $csv.Add($ThisRow)
            } else {
                $script:csv = @($ThisRow)
            }
        }
        $wpf.CSVGrid.ScrollIntoView($wpf.CSVGrid.Items[-1], $wpf.CSVGrid.Columns[0])

    } else {
        # InsertAbove/InsertBelow
        $At = $csv.IndexOf($wpf.CSVGrid.SelectedItem)
        $Count = $wpf.CSVGrid.SelectedItems.Count
        if ($Action -eq 'InsertBelow') {$At += $Count}

        # Max & Min to prevent under/overflowing
        for ($i = 0; $i -lt $Count; $i++) {
            $csv.Insert(
                [Math]::Max(0, [Math]::Min($At,$csv.Count)),
                $RowTemplate.PSObject.Copy()
            )
        }
    }

    $wpf.Commit.IsEnabled = $true
    $wpf.CSVGrid.ItemsSource = $csv
    $wpf.CSVGrid.Items.Refresh()
}
