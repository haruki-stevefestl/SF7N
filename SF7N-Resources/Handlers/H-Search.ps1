# Start search
$wpf.SearchBar.Add_TextChanged({
    if ($wpf.SearchBar.Text -match '[\r\n]') {
        $wpf.SearchBar.Text = $wpf.SearchBar.Text -replace '[\r\n]', ''
        Search-CSV $wpf.SearchBar.Text
    }
})
$wpf.Search.Add_Click({Search-CSV $wpf.SearchBar.Text})

# Set preview on cell change
$wpf.CSVGrid.Add_SelectionChanged({
    # Evaluate <.+?> notations
    $Preview = $ExecutionContext.InvokeCommand.ExpandString($dataContext.PreviewPath)
    $Replacements = $Preview | Select-String '(?<=<)(.+?)(?=>)' -AllMatches
    $Replacements.Matches.Value.ForEach({
        $Preview = $Preview.Replace("<$_>", $wpf.CSVGrid.SelectedItem.$_)
    })
    Set-DataContext Preview $Preview
})

# Copy preview
$wpf.PreviewCopy.Add_Click({
    if ($dataContext.Preview) {
        [Windows.Forms.Clipboard]::SetImage([Drawing.Image]::FromFile(
            $dataContext.Preview
        ))
    }
})

# Open config page
$wpf.Settings.Add_Click({Set-DataContext Status Configurating})