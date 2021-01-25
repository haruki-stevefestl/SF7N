#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Search-related actions
$wpf.Search.Add_Click({Search-CSV})

$wpf.CSVGrid.Add_MouseUp({Set-Preview $wpf.CSVGrid.SelectedItem.ID})
$wpf.CSVGrid.Add_Keyup({Set-Preview $wpf.CSVGrid.SelectedItem.ID})

# Editing-related actions
# Entering editing mode
$wpf.CSVGrid.Add_BeginningEdit({
    if ($wpf.Toolbar.SelectedIndex -ne 1) {
        Write-Log 'DBG' 'Editing Mode On'
        $script:editingMode = $true
        $wpf.Toolbar.SelectedIndex = 1

        # Expand CSV and focus on oringally selected row
        $SelectedItem = $wpf.CSVGrid.CurrentCell[0].Item
        $wpf.CSVGrid.ItemsSource  = $null
        $wpf.CSVGrid.Items.Clear()
        $wpf.CSVGrid.ItemsSource  = $csvRaw
        $NewSelectedItem = $wpf.CSVGrid.Items | Where-Object {$_.ID -eq $SelectedItem.ID}
        $wpf.CSVGrid.SelectedItem = $NewSelectedItem
        $wpf.CSVGrid.ScrollIntoView($NewSelectedItem)

        $wpf.CSVGrid.BeginEdit()
    }
})

# Commit actions
$wpf.Commit.Add_Click({Export-CustomCSV $csvLocation})

$wpf.CommitReturn.Add_Click({
    Export-CustomCSV $csvLocation
    $wpf.Toolbar.SelectedIndex = 0
    Search-CSV
})
