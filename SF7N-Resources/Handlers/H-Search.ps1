# Start search
$wpf.SearchRules.Add_TextChanged{
    if ($wpf.SearchRules.Text[-1] -eq "`n") {
        $wpf.SearchRules.Text = $wpf.SearchRules.Text -replace '[\r\n]', ''
        $wpf.SearchRules.SelectionStart = $wpf.SearchRules.Text.Length
        Search-CSV $wpf.SearchRules.Text
    }
}
$wpf.AliasMode.Add_Checked{Search-CSV $wpf.SearchRules.Text}
$wpf.ReadWrite.Add_Checked{Search-CSV $wpf.SearchRules.Text}

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
