$wpf.ApplyConfig.Add_Click({
    # Handle RadioButton -> $context.EditOutput
    if ($wpf.ReadAlias.IsChecked) {
        Set-DataContext EditOutput 0
    } elseif ($wpf.ReadRaw.IsChecked) {
        Set-DataContext EditOutput 1
    } else {
        Set-DataContext EditOutput 2
    }

    # Export config to file
    (
        'csvLocation  = ' + $context.csvLocation.Replace('\','\\') + "`n",
        'PreviewPath  = ' + $context.PreviewPath.Replace('\','\\') + "`n",
        'Theme        = ' + $context.Theme + "`n",
        'InputAlias   = ' + $context.InputAlias   + "`n",
        'AppendFormat = ' + $context.AppendFormat + "`n",
        'AppendCount  = ' + $context.AppendCount  + "`n",
        'EditOutput   = ' + $context.EditOutput   + "`n"
    ) | Out-File '.\Configurations\General.ini'

    # Reload
    Import-Configuration .\Configurations\General.ini
    if ($config.csvLocation -ne $context.csvLocation) {
        Write-Log 'Reload all'
        Initialize-SF7N

    } elseif (
        $config.EditOutput -ne $context.EditOutput -or
        $config.InputAlias -ne $context.InputAlias
    ) {
        Write-Log 'Reload search'
        Search-CSV $wpf.SearchBar.Text
    }
    Set-DataContext Status 'Ready'
})

$wpf.ResetConfig.Add_Click({
    $config.GetEnumerator().ForEach({
        Set-DataContext $_.Keys ([String] $_.Values)
    })
})
