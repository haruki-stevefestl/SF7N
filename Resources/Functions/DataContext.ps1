function Import-Configuration ($ImportFrom) {
    Write-Log 'Import Configuration'
    return Get-Content $ImportFrom | ConvertFrom-StringData
}

function Update-DataContext {
    # Update DataContext manually as INPC is difficult to implement
    # https://stackoverflow.com/q/21814444
    $wpf.SF7N.DataContext = $null
    $wpf.SF7N.DataContext = $context
}

function Set-DataContext ($Key, $Value) {
    $context.$Key = $Value
    Update-DataContext
}

function New-DataContext ($Key) {
    Write-Log 'New    DataContext'
    return ([PSCustomObject] @{
        csvLocation  = $Key.csvLocation
        PreviewPath  = $Key.PreviewPath
        Theme        = $Key.Theme
        AppendFormat = $Key.AppendFormat
        AppendCount  = $Key.AppendCount
        InputAlias   = $Key.InputAlias -ieq 'true'
        EditOutput   = $Key.EditOutput
        Status       = 'Initializing'
        Preview      = $null
    })
}
