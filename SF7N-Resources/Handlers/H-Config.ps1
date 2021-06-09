# Actions related to changing config at runtime
$wpf.Settings.Add_Click({
    if (!$wpf.Settings.IsChecked) {
        # Export config to file
        (
            'csvLocation  = ' + $wpf.Config_CSVLocation.Text.Replace('\','\\') + "`n",
            'PreviewPath  = ' + $wpf.Config_PreviewPath.Text.Replace('\','\\') + "`n",
            'InputAssist  = ' + $wpf.Config_InputAssist.IsChecked + "`n",
            'InsertLast   = ' + $wpf.Config_AppendCount.Text + "`n",
            'AppendFormat = ' + $wpf.Config_AppendFormat.Text + "`n",
            'AliasMode    = ' + $wpf.Config_AliasMode.IsChecked + "`n",
            'ReadWrite    = ' + $wpf.Config_ReadWrite.IsChecked
        ) | Set-Content '.\Configurations\General.ini'

        # Reinitalize if locational variables changed
        if (
            $config.csvLocation -ne $wpf.Config_CSVLocation.Text -or
            $config.PreviewPath -ne $wpf.Config_PreviewPath.Text
        ) {
            Invoke-Initialization
        }
        Search-CSV $wpf.SearchBar.Text
    }
})