#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Search-related actions
$wpf.Search.Add_Click({Search-CSV})

$wpf.CSVGrid.Add_MouseUp({Set-Preview $wpf.CSVGrid.CurrentCell.Item.ID})
$wpf.CSVGrid.Add_Keyup({Set-Preview $wpf.CSVGrid.CurrentCell.Item.ID})

#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Editing-related actions
# Enter edit mode
$wpf.CSVGrid.Add_BeginningEdit({
    if ($wpf.Toolbar.SelectedIndex -eq 0) {
        # Enable editing toolbar
        $wpf.Toolbar.SelectedIndex = 1
        $wpf.CurrentMode.Text = 'Edit Mode'
        $wpf.TotalRows.Text = "Total rows: $($csvRaw.Count)"
        
        # Capture current active cell
        $CurrentCell = $wpf.CSVGrid.CurrentCell[0]
        
        # Change Itemssource (to show all rows in CSV)
        $wpf.CSVGrid.ItemsSource = $null
        $wpf.CSVGrid.Items.Clear()
        $wpf.CSVGrid.ItemsSource = $csvRaw

        # Refocus on captured cell
        $wpf.CSVGrid.ScrollIntoView($(
            $wpf.CSVGrid.Items | Where-Object {$_.ID -eq $CurrentCell.Item.ID}
        ))
        $wpf.CSVGrid.SelectedCells.Add($wpf.CSVGrid.CurrentCell[0])
        $wpf.CSVGrid.BeginEdit() 
    }
})

# Invoke-ChangeRow actions
$wpf.InsertLast.Add_Click({
    Invoke-ChangeRow 'InsertLast' -Count $wpf.InsertLastCount.Text
})

$wpf.InsertAbove.Add_Click({
    $Params = @{
        At    = $wpf.CSVGrid.Items.IndexOf($wpf.CSVGrid.SelectedCells[0].Item)
        Count = $wpf.CSVGrid.SelectedCells.Count
    }
    Invoke-ChangeRow 'InsertAbove' @Params
})

$wpf.InsertBelow.Add_Click({
    $Params = @{
        At    = $wpf.CSVGrid.Items.IndexOf($wpf.CSVGrid.SelectedCells[0].Item)
        Count = $wpf.CSVGrid.SelectedCells.Count
    }
    Invoke-ChangeRow 'InsertBelow' @Params
})

$wpf.RemoveSelected.Add_Click({Invoke-ChangeRow 'Remove'})

# Export CSV on Commit
$wpf.Commit.Add_Click({Export-CustomCSV $csvLocation})

# Reload CSV on Commit & Return
$wpf.CommitReturn.Add_Click({
    $wpf.CurrentMode.Text = 'Search Mode'
    $wpf.TotalRows.Text = "Total rows: $($csv.Count)"

    Export-CustomCSV $csvLocation
    Import-CustomCSV $csvLocation
    $wpf.CSVGrid.ItemsSource = $csv
    $wpf.Toolbar.SelectedIndex = 0
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