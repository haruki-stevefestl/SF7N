#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Intertab movements
$wpf.GotoDebug.Add_Click({$wpf.TabControl.SelectedIndex = 2})
$wpf.GotoDefault.Add_Click({$wpf.TabControl.SelectedIndex = 1})

#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Search-related actions
$wpf.Search.Add_Click({Search-CSV})

$wpf.CSVGrid.Add_MouseUp({Set-Preview})
$wpf.CSVGrid.Add_Keyup({Set-Preview})

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
        $script:CurrentCell = $wpf.CSVGrid.CurrentCell[0]
        
        # Change Itemssource (to show all rows in CSV)
        $wpf.CSVGrid.ItemsSource = $null
        $wpf.CSVGrid.Items.Clear()
        $wpf.CSVGrid.ItemsSource = $csv

        # PROBLEM: CSVGRID ITEMS MAY BE ALIAS MODED

        # Refocus on captured cell
        $wpf.CSVGrid.ScrollIntoView($(
            $wpf.CSVGrid.Items.($csvHeader[0]) | Where-Object {$_ -eq $CurrentCell.Item.($csvHeader[0])}
        ))
        $wpf.CSVGrid.BeginEdit() 
    }
})

# Invoke-ChangeRow actions
$wpf.InsertLast.Add_Click({
    Invoke-ChangeRow 'InsertLast' $wpf.InsertLastCount.Text
})
$wpf.InsertAbove.Add_Click({Invoke-ChangeRow 'InsertAbove'})
$wpf.InsertBelow.Add_Click({Invoke-ChangeRow 'InsertBelow'})
$wpf.RemoveSelected.Add_Click({Invoke-ChangeRow 'Remove'})

# Export CSV on Commit
$wpf.Commit.Add_Click({
    # Export-Configuration
    Export-CustomCSV $csvLocation
})

# Reload CSV on Commit & Return
$wpf.CommitReturn.Add_Click({
    $wpf.CurrentMode.Text = 'Search Mode'
    $wpf.TotalRows.Text = "Total rows: $($csv.Count)"

    # Export-Configuration
    Export-CustomCSV $csvLocation
    Import-CustomCSV $csvLocation
    $wpf.CSVGrid.ItemsSource = $csv
    $wpf.Toolbar.SelectedIndex = 0
    # Search-CSV
})

#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Debugger
$wpf.Debug.Add_Click({
    $PreviousMode = $wpf.CurrentMode.Text
    $wpf.CurrentMode.Text = 'Debug Mode'
    Write-Host 'SF7N Debugger - Enter "break" to exit session'
    Write-Host '---------------------------------------------'
    while ($true) {
        Write-Host "SF7N > " -NoNewLine
        $Host.UI.ReadLine() | Invoke-Expression | Out-Host
    }
    $wpf.CurrentMode.Text = $PreviousMode
})
