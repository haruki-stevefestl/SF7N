function Import-Configuration ($ImportFrom) {
    Write-Log 'Import Configuration'
    return Get-Content $ImportFrom | ConvertFrom-StringData
}

function Expand-Path ($Path) {
    return ($ExecutionContext.InvokeCommand.ExpandString($Path))
}

function Update-DataContext ($DataContext) {
    # Update DataContext manually as INPC is difficult to implement
    # https://stackoverflow.com/q/21814444
    $wpf.SF7N.DataContext = $null
    $wpf.SF7N.DataContext = $DataContext
}

function Set-DataContext ($ToChange, $Key, $Value) {
    $ToChange.$Key = $Value
    Update-DataContext $ToChange
}

function New-DataContext ($Key) {
    Write-Log 'New    DataContext'
    $DataContext =[PSCustomObject] @{
        csvLocation  = $Key.csvLocation
        PreviewPath  = $Key.PreviewPath
        Theme        = $Key.Theme
        AppendFormat = $Key.AppendFormat
        AppendCount  = $Key.AppendCount
        InputAlias   = $Key.InputAlias -ieq 'true'
        EditOutput  = @($False) * 3
        Status       = 'Ready'
        Preview      = $null
    }
    
    # .EditOutput is an array of three boolean values,
    # each representing the IsChecked of a EditOutput checkbox 
    $DataContext.EditOutput[$Key.EditOutput] = $true

    return $DataContext
}