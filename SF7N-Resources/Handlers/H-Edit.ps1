# Editing-related actions
# Enter edit mode
$wpf.CSVGrid.Add_BeginningEdit({$wpf.Toolbar.SelectedIndex = 1})

# Add-Row actions
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
$wpf.Commit.Add_Click({Export-CustomCSV $dataContext.csvLocation})

# Reload CSV on Return
$wpf.Return.Add_Click({
    $Return = $true
    if ($wpf.Commit.IsEnabled) {
        switch (New-SaveDialog) {
            'Yes'    {Export-CustomCSV $dataContext.csvLocation}
            'Cancel' {$Return = $false}
        }
    }

    if ($Return) {
        Import-CustomCSV $dataContext.csvLocation
        $wpf.CSVGrid.ItemsSource = $csv
        $wpf.Commit.IsEnabled = $false
        $wpf.Toolbar.SelectedIndex = 0
    }
})