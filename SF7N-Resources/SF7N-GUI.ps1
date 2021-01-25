#—————————————————————————————————————————————————————————————————————————————+—————————————————————
$wpf.Search.Add_Click({Search-CSV})

$wpf.CSVGrid.Add_MouseUp({Set-Preview $wpf.CSVGrid.SelectedItem.ID})
$wpf.CSVGrid.Add_Keyup({Set-Preview $wpf.CSVGrid.SelectedItem.ID})