$wpf.ApplyConfig.Add_Click({

    # Export config to file
    (
        'csvLocation  = ' + $context.csvLocation.Replace('\','\\') + "`n" +
        'PreviewPath  = ' + $context.PreviewPath.Replace('\','\\') + "`n" +
        'Theme        = ' + $context.Theme        + "`n" +
        'AppendFormat = ' + $context.AppendFormat + "`n" +
        'AppendCount  = ' + $context.AppendCount  + "`n" +
        'InputAlias   = ' + $context.InputAlias   + "`n" +
        'OutputAlias  = ' + $context.OutputAlias  + "`n" +
        'OutputRaw    = ' + $context.OutputRaw    + "`n" +
        'ReadWrite    = ' + $context.ReadWrite    + "`n"
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
        Search-CSV $wpf.Searchbar.Text
    }
    $wpf.TabControl.SelectedIndex = 1
})

$wpf.ResetConfig.Add_Click({
    # Update DataContext manually as INPC is difficult to implement
    # https://stackoverflow.com/q/21814444
    $config.Keys.Foreach({$context.$_ = $config.$_})
    $wpf.SF7N.DataContext = $null
    $wpf.SF7N.DataContext = $context
})
