# Actions related to changing config at runtime
$wpf.Settings.Add_Click({
    if (!$wpf.Settings.IsChecked) {
        # Export config to file
        (
            'csvLocation  = ' + $wpf.Config_CSVLocation.Text.Replace('\','\\') + "`n",
            'previewPath  = ' + $wpf.Config_PreviewLocation.Text.Replace('\','\\') + "`n",
            'InputAssist  = ' + $wpf.Config_InputAssist.IsChecked + "`n",
            'InsertLast   = ' + $wpf.Config_AppendCount.Text + "`n",
            'AppendFormat = ' + $wpf.Config_AppendFormat.Text + "`n",
            'AliasMode    = ' + $wpf.Config_AliasMode.IsChecked + "`n",
            'ReadWrite    = ' + $wpf.Config_ReadWrite.IsChecked
        ) | Set-Content '.\Configurations\General.ini'

        # Reload
        Invoke-Initialization
    }
})