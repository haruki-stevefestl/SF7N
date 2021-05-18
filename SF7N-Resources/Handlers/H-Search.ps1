# Start search
$wpf.Search.Add_Click{Search-CSV $wpf.SearchRules.Text}
$wpf.SearchRules.Add_TextChanged{
    if ($wpf.TabSearch.IsChecked -and ($wpf.SearchRules.Text[-1] -eq "`t")) {
        Search-CSV $wpf.SearchRules.Text
    }
}

# Reset sorting
$wpf.ResetSorting.Add_Click{
    $wpf.CSVGrid.Items.SortDescriptions.Clear()
    $wpf.CSVGrid.Columns.ForEach{$_.SortDirection = $null}
}

# Set preview on cell change
$wpf.CSVGrid.Add_SelectionChanged{
    # Evaluate <.+?> notations
    $PreviewPath = $previewLocation
    $Replacements = $previewLocation | Select-String '(?<=<)(.+?)(?=>)' -AllMatches
    $Replacements.Matches.Value.ForEach{
        $PreviewPath = $PreviewPath.Replace("<$_>", $wpf.CSVGrid.SelectedItems[0].$_)
    }

    # Set preview
    try {
        $wpf.PreviewImage.Source = $PreviewPath
    } catch {$wpf.PreviewImage.Source = $null}
}

# Copy preview
$wpf.PreviewCopy.Add_Click{
    if ($wpf.PreviewImage.Source) {
        [Windows.Forms.Clipboard]::SetImage([Drawing.Image]::FromFile(
            $wpf.PreviewImage.Source.Replace('file:///','')
        ))
    }
}

# AliasMode - ReadOnly
$wpf.AliasMode.Add_Click{
    if ($wpf.AliasMode.IsChecked) {
        $script:oldReadOnly = $wpf.ReadOnly.IsChecked
        $wpf.ReadOnly.IsChecked = $true
        $wpf.ReadOnly.IsEnabled = $false
    } else {
        $wpf.ReadOnly.IsEnabled = $true
        $wpf.ReadOnly.IsChecked = $oldReadOnly
    }
    Search-CSV $wpf.SearchRules.Text
}

$wpf.ReadOnly.Add_Click{
    if (!$wpf.ReadOnly.IsChecked) {
        $wpf.AliasMode.IsEnabled = $true
    }
}
