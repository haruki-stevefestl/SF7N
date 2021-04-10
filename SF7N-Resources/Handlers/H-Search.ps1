#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Search-related actions
$wpf.Search.Add_Click({New-Search $wpf.SearchRules.Text})

$wpf.CSVGrid.Add_MouseUp({Set-Preview})
$wpf.CSVGrid.Add_Keyup({Set-Preview})

$wpf.ResetSorting.Add_Click({
    $wpf.CSVGrid.Items.SortDescriptions.Clear()
    $wpf.CSVGrid.Columns.ForEach({$_.SortDirection = $null})
})

$wpf.ReadOnly.Add_Click({
    $wpf.CSVGrid.IsReadOnly = $wpf.ReadOnly.IsChecked
    $wpf.CurrentMode.Text = 'Search Mode'
    if ($wpf.ReadOnly.IsChecked) {
        $wpf.ReadOnlyText.Text = 'Read-Only '
    } else {
        $wpf.ReadOnlyText.Text = 'Read/Write'
    }
})
