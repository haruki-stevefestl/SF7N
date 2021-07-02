# Enter edit mode
$wpf.CSVGrid.Add_BeginningEdit({
    # Repeatedly setting DataContext causes changes to vanish
    if ($context.Status -ne 'Editing') {
        Set-DataContext $context Status Editing
    }
})

# Change rows (add/remove)
$wpf.CSVGrid.Add_CellEditEnding({$wpf.Commit.IsEnabled = $true})
$wpf.InsertLast.Add_Click({ Add-Row 'InsertLast'})
$wpf.InsertAbove.Add_Click({Add-Row 'InsertAbove'})
$wpf.InsertBelow.Add_Click({Add-Row 'InsertBelow'})
$wpf.RemoveSelected.Add_Click({
    $wpf.CSVGrid.SelectedItems.ForEach{$csv.Remove($_)}
    $wpf.CSVGrid.ItemsSource = $csv
    $wpf.CSVGrid.Items.Refresh()
    $wpf.Commit.IsEnabled = $true
})

# Commit CSV
$wpf.Commit.Add_Click({Export-CustomCSV $context.csvLocation})

# Reload CSV on return; ask user if unsaved
$wpf.Return.Add_Click({
    $Return = $true
    if ($wpf.Commit.IsEnabled) {
        switch (New-SaveDialog) {
            'Yes'    {Export-CustomCSV $context.csvLocation}
            'Cancel' {$Return = $false}
        }
    }

    if ($Return) {
        Import-CustomCSV $context.csvLocation
        Search-CSV $wpf.SearchBar.Text
    }
})
