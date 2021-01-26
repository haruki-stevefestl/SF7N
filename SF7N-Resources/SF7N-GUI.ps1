#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Search-related actions
$wpf.Search.Add_Click({Search-CSV})

$wpf.CSVGrid.Add_MouseUp({Set-Preview $wpf.CSVGrid.SelectedItem.ID})
$wpf.CSVGrid.Add_Keyup({Set-Preview $wpf.CSVGrid.SelectedItem.ID})

# Editing-related actions
$wpf.CSVGrid.Add_BeginningEdit({
    # don't
    if ($wpf.Toolbar.SelectedIndex -eq 0) {
        # Enable editing mode
        $wpf.Toolbar.SelectedIndex = 1
        
        $global:CurrentCell = $wpf.CSVGrid.CurrentCell[0]
        $wpf.CSVGrid.ItemsSource = $null
        $wpf.CSVGrid.Items.Clear()
        $wpf.CSVGrid.ItemsSource = $csvRaw

        $global:NewCurrentCell = $wpf.CSVGrid.Items | Where-Object {$_.ID -eq $CurrentCell.Item.ID}

        $wpf.CSVGrid.ScrollIntoView($NewCurrentCell)
        # $global:NewCurrentCellInfo = [System.Windows.Controls.DataGridCellInfo]::new($NewCurrentCell, $CurrentCell.Column.DisplayIndex)
        # $wpf.CSVGrid.CurrentCell = New-Object System.Windows.Controls.DataGridCellInfo $NewCurrentCell, $CurrentCell.Column.DisplayIndex
        $wpf.CSVGrid.SelectedCells.Add($wpf.CSVGrid.CurrentCell[0])

        # $global:NewCurrentCell = $wpf.CSVGrid.Items | Where-Object {$_ -eq $CurrentCell.Item}
        # Write-Host $NewCurrentCell | Out-Host
        $wpf.CSVGrid.BeginEdit() 
    }
})

$wpf.Commit.Add_Click({Export-CustomCSV $csvLocation})
$wpf.CommitReturn.Add_Click({
    Export-CustomCSV $csvLocation
    Import-CustomCSV $csvLocation
    $wpf.CSVGrid.ItemsSource = $csv
    $wpf.Toolbar.SelectedIndex = 0
})

# Debugger
$wpf.Debug.Add_Click({
    Write-Host 'SF7N Debugger - Enter "break" to exit section'
    Write-Host '---------------------------------------------'
    while ($true) {
        Write-Host "SF7N > " -NoNewLine
        $Host.UI.ReadLine() | Invoke-Expression | Out-Host
    }
})