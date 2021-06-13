# Actions related to changing config at runtime
$wpf.SettingsReturn.Add_Click({
    # Export config to file
    (
        'csvLocation  = ' + $context.csvLocation.Replace('\','\\') + "`n",
        'PreviewPath  = ' + $context.PreviewPath.Replace('\','\\') + "`n",
        'Theme        = ' + $context.Theme + "`n",
        'InputAssist  = ' + $context.InputAssist + "`n",
        'AppendFormat = ' + $context.AppendFormat + "`n",
        'AppendCount  = ' + $context.AppendCount + "`n",
        'AliasMode    = ' + $context.AliasMode + "`n",
        'ReadWrite    = ' + $context.ReadWrite
    ) | Out-File '.\Configurations\General.ini'

    # Reload
    $script:config = Get-Content .\Configurations\General.ini | ConvertFrom-StringData
    Initialize-SF7N
})