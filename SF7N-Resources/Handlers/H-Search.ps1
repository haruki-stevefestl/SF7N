# Start search
$wpf.Search.Add_Click({Search-CSV $wpf.SearchRules.Text})
$wpf.SearchRules.Add_TextChanged({
    if ($wpf.TabSearch.IsChecked -and ($wpf.SearchRules.Text[-1] -eq "`t")) {
        Search-CSV $wpf.SearchRules.Text
    }
}) 

# Reset sorting
$wpf.ResetSorting.Add_Click({
    $wpf.CSVGrid.Items.SortDescriptions.Clear()
    $wpf.CSVGrid.Columns.ForEach({$_.SortDirection = $null})
})

# Set preview on cell change
$wpf.CSVGrid.Add_SelectionChanged({
    # Evaluate <.+?> notations
    $PreviewPath = $previewLocation
    $Temp = $previewLocation | Select-String '(?<=<)(.+?)(?=>)' -AllMatches
    $Temp.Matches.Value.ForEach({
        $PreviewPath = $previewPath.Replace("<$_>", ($wpf.CSVGrid.SelectedItems[0].($_)))
    })

    # Set preview
    try {
        $wpf.PreviewImage.Source = $PreviewPath
    } catch {$wpf.PreviewImage.Source = $null}
})

# Copy preview
$wpf.PreviewCopy.Add_Click({
    if ($null -ne $wpf.PreviewImage.Source) {
        [Windows.Forms.Clipboard]::SetImage([Drawing.Image]::FromFile(
            $wpf.PreviewImage.Source -replace 'file:///',''
        ))
    }
})
