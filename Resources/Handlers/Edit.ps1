# Enter edit mode
$wpf.CSVGrid.Add_BeginningEdit({$wpf.Status.Text = 'Editing'})

# Change rows (add/remove)
$wpf.CSVGrid.Add_CellEditEnding({$wpf.Commit.IsEnabled = $true})
$wpf.InsertLast.Add_Click({ Add-Row 'InsertLast'})
$wpf.InsertAbove.Add_Click({Add-Row 'InsertAbove'})
$wpf.InsertBelow.Add_Click({Add-Row 'InsertBelow'})
$wpf.RemoveSelected.Add_Click({
    $wpf.CSVGrid.SelectedItems.ForEach{$csv.Remove($_)}
    $wpf.CSVGrid.ItemsSource = $csv
    $wpf.CSVGrid.Items.Refresh()
    $wpf.Commit.IsEnabled = [Boolean] $csv # Disable commit button if $csv is empty
})

# Commit CSV
$wpf.Commit.Add_Click({Export-CustomCSV $context.csvLocation})

# Reload CSV on return; ask user if unsaved
$wpf.Return.Add_Click({
    $Return = $true
    if ($wpf.Commit.IsEnabled) {
        $Dialog = New-Dialog 'Commit changes before exiting?' 'YesNoCancel' 'Question'
        if ($Dialog -eq 'Yes') {
            Export-CustomCSV $context.csvLocation

        } elseif ($Dialog -eq 'Cancel') {
            $Return = $false
        }
    }

    if ($Return) {
        Import-CustomCSV $context.csvLocation
        Search-CSV $wpf.Searchbar.Text $csv
    }
})
