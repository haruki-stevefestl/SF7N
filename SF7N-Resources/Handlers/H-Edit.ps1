#——————————————————————————————————————————————————————————————————————————————+————————————————————
# Editing-related actions
# Enter edit mode
$wpf.CSVGrid.Add_BeginningEdit({
    if ($wpf.Toolbar.SelectedIndex -eq 0) {
        # Enable editing toolbar
        $wpf.Toolbar.SelectedIndex = 1
        $wpf.CurrentMode.Text = 'Edit Mode'
        $wpf.TotalRows.Text = "Total rows: $($csv.Count)"
        
        # Capture current active cell
        $CurrentCell = ConvertFrom-AliasMode $wpf.CSVGrid.CurrentCell[0].Item
        $CurrentCellColumn = $wpf.CSVGrid.CurrentCell[0].Column.DisplayIndex
        
        # Show all rows in CSV
        $wpf.CSVGrid.ItemsSource = $csv

        # Refocus on captured cell
       for ($i = 0; $i -lt $csv.count; $i++) {
            if (
                $wpf.CSVGrid.Items[$i] -eq $CurrentCell
            ) {
                $wpf.CSVGrid.ScrollIntoView($wpf.CSVGrid.Items[$i])
                $wpf.CSVGrid.CurrentCell = [Windows.Controls.DataGridCellInfo]::New(
                    $wpf.CSVGrid.Items[$i],
                    $wpf.CSVGrid.Columns[$CurrentCellColumn]
                )
                $wpf.CSVGrid.BeginEdit()
                break
            }
        }
    }
})

# Add-Row actions
$wpf.CSVGrid.Add_CellEditEnding({$wpf.Commit.IsEnabled = $true})
$wpf.InsertLast.Add_Click({ Add-Row 'InsertLast' })
$wpf.InsertAbove.Add_Click({Add-Row 'InsertAbove'})
$wpf.InsertBelow.Add_Click({Add-Row 'InsertBelow'})
$wpf.RemoveSelected.Add_Click({
    Write-Log 'INF' 'Change Rows: Remove selected rows'
    $wpf.Commit.IsEnabled = $true
    $wpf.CSVGrid.SelectedCells.ForEach({$csv.Remove($_.Item)})
    $wpf.CSVGrid.ItemsSource = $csv
    $wpf.CSVGrid.Items.Refresh()
    Update-GUI
})


$wpf.Commit.Add_Click({Export-CustomCSV $csvLocation})

# Reload CSV on Return
$wpf.Return.Add_Click({
    $Return = $true
    if ($wpf.Commit.IsEnabled) {
        switch (New-SaveDialog) {
            'Yes'    {Export-CustomCSV $csvLocation}
            'Cancel' {$Return = $false}
        }
    }

    if ($Return) {
        $wpf.CurrentMode.Text = 'Search Mode'
        $wpf.Commit.IsEnabled = $false

        Import-CustomCSV $csvLocation
        Search-CSV $wpf.SearchRules.Text
        $wpf.TotalRows.Text = "Total rows: $($csv.Count)"

        $wpf.Toolbar.SelectedIndex = 0
    }
})
