#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Search-related actions
$wpf.Search.Add_Click({Search-CSV})

$wpf.CSVGrid.Add_MouseUp({Set-Preview $wpf.CSVGrid.SelectedItem.ID})
$wpf.CSVGrid.Add_Keyup({Set-Preview $wpf.CSVGrid.SelectedItem.ID})

# Editing-related actions
$editingMode = $false
$wpf.CSVGrid.Add_BeginningEdit({
    $script:editingMode = $true
    $wpf.Toolbar.SelectedIndex = 1
    Write-Log 'DBG' 'Editing Mode On'
})

# On Commit/Commit&Return
# $wpf.CSVGrid.Add_RowEditEnding({
    # $script:editingMode = $false
    # $wpf.Toolbar.SelectedIndex = 0
    # Write-Log 'DBG' 'Editing Mode Off'
# })