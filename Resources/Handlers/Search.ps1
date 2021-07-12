# Start search
$wpf.Searchbar.Add_TextChanged({
    $PrevCursor = $wpf.Searchbar.SelectionStart - 2
    if ($wpf.Searchbar.Text -match '[\r\n]') {
        $wpf.Searchbar.Text = $wpf.Searchbar.Text -replace '[\r\n]'
        $wpf.Searchbar.SelectionStart = $PrevCursor

        Search-CSV $wpf.Searchbar.Text $csv
    }
})
$wpf.Search.Add_Click({Search-CSV $wpf.Searchbar.Text $csv})

# Set preview on cell change
$wpf.CSVGrid.Add_SelectionChanged({
    # Expand <.+?> notation
    $Preview = Expand-Path $context.PreviewPath
    $Regex   = '(?<=<)(.+?)(?=>)'
    ($Preview | Select-String $Regex -AllMatches).Matches.Value.ForEach({
        $Preview = $Preview.Replace("<$_>", $wpf.CSVGrid.SelectedItem.$_)
    })
    
    if (Test-Path $Preview) {$wpf.Preview.Source = $Preview}
})

# Copy preview
$wpf.PreviewCopy.Add_Click({
    if (Test-Path $wpf.Preview.Source) {
        [Windows.Forms.Clipboard]::SetImage([Drawing.Image]::FromFile(
            $wpf.Preview.Source
        ))
    }
})

# Open config page
$wpf.Settings.Add_Click({$wpf.TabControl.SelectedIndex = 2})
