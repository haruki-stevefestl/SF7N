# Actions related to changing config at runtime
$wpf.SettingsReturn.Add_Click({
    # Export config to file
    (
        'csvLocation  = ' + $dataContext.csvLocation.Replace('\','\\') + "`n",
        'PreviewPath  = ' + $dataContext.PreviewPath.Replace('\','\\') + "`n",
        'DarkMode     = ' + $dataContext.DarkMode + "`n",
        'InputAssist  = ' + $dataContext.InputAssist + "`n",
        'AppendFormat = ' + $dataContext.AppendFormat + "`n",
        'AppendCount  = ' + $dataContext.AppendCount + "`n",
        'AliasMode    = ' + $dataContext.AliasMode + "`n",
        'ReadWrite    = ' + $dataContext.ReadWrite
    ) | Out-File '.\Configurations\General.ini'

    # Reload
    Initialize-SF7N
})