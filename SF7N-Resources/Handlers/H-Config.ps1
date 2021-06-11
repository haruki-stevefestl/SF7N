# Actions related to changing config at runtime
$wpf.Settings.Add_Unchecked({
    # Export config to file
    (
        'csvLocation  = ' + $dataContext.csvLocation.Replace('\','\\') + "`n",
        'PreviewPath  = ' + $dataContext.PreviewPath.Replace('\','\\') + "`n",
        'InputAssist  = ' + $dataContext.InputAssist + "`n",
        'AppendFormat = ' + $dataContext.AppendFormat + "`n",
        'AppendCount  = ' + $dataContext.AppendCount + "`n",
        'AliasMode    = ' + $dataContext.AliasMode + "`n",
        'ReadWrite    = ' + $dataContext.ReadWrite
    ) | Set-Content '.\Configurations\General.ini'

    # Reload
    Invoke-Initialization
})