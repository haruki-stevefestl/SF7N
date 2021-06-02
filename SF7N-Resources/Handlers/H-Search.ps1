# Start search
$wpf.SearchBar.Add_TextChanged{
    if ($wpf.SearchBar.Text -match '[\r\n]') {
        $wpf.SearchBar.Text = $wpf.SearchBar.Text -replace '[\r\n]', ''
        Search-CSV $wpf.SearchBar.Text
    }
}
$wpf.Search.Add_Click{Search-CSV $wpf.SearchBar.Text}
$wpf.AliasMode.Add_Checked{Search-CSV $wpf.SearchBar.Text}
$wpf.ReadWrite.Add_Checked{Search-CSV $wpf.SearchBar.Text}

# Set preview on cell change
$wpf.CSVGrid.Add_SelectionChanged{
    # Evaluate <.+?> notations
    $PreviewPath = $previewLocation
    $Replacements = $previewLocation | Select-String '(?<=<)(.+?)(?=>)' -AllMatches
    $Replacements.Matches.Value.ForEach{
        $PreviewPath = $PreviewPath.Replace("<$_>", $wpf.CSVGrid.SelectedItem.$_)
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
            $wpf.PreviewImage.Source -replace 'file:///',''
        ))
    }
}
