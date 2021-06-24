# Actions related to changing config at runtime
$wpf.ApplyConfig.Add_Click({
    # Export config to file
    (
        'csvLocation  = ' + $context.csvLocation.Replace('\','\\') + "`n",
        'PreviewPath  = ' + $context.PreviewPath.Replace('\','\\') + "`n",
        'Theme        = ' + $context.Theme + "`n",
        'InputAlias   = ' + $context.InputAlias + "`n",
        'AppendFormat = ' + $context.AppendFormat + "`n",
        'AppendCount  = ' + $context.AppendCount + "`n",
        'OutputAlias  = ' + $context.OutputAlias + "`n",
        'RawMode      = ' + $context.RawMode + "`n",
        'ReadWrite    = ' + $context.ReadWrite
    ) | Out-File '.\Configurations\General.ini'

    # Reload
    if ($config.csvLocation -ne $context.csvLocation) {
        Write-Log 'DBG' 'Reload all'
        Initialize-SF7N

    } elseif (
        $config.OutputAlias -ne $context.OutputAlias -or
        $config.RawMode -ne $context.RawMode -or
        $config.ReadWrite -ne $context.ReadWrite
    ) {
        Write-Log 'DBG' 'Reload search'
        Search-CSV $wpf.SearchBar.Text
    }
    Import-Configuration
    Set-DataContext Status 'Ready'
})

$wpf.ResetConfig.Add_Click({
    $config.GetEnumerator().ForEach({
        Set-DataContext $_.Keys ([String] $_.Values)
    })
})
