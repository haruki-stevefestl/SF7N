function Import-Configuration ($ImportFrom) {
    Write-Log 'Import Configuration'
    return Get-Content $ImportFrom | ConvertFrom-StringData
}

function Expand-Path ($Path) {
    return ($ExecutionContext.InvokeCommand.ExpandString($Path))
}

function New-DataContext ($Key) {
    Write-Log 'New    DataContext'
    return ([PSCustomObject] @{
        csvLocation  = $Key.csvLocation
        PreviewPath  = $Key.PreviewPath
        Theme        = $Key.Theme
        AppendFormat = $Key.AppendFormat
        AppendCount  = $Key.AppendCount
        InputAlias   = $Key.InputAlias  -ieq 'true'
        OutputAlias  = $Key.OutputAlias -ieq 'true'
        ReadWrite    = $Key.ReadWrite   -ieq 'true'
        Status       = 'Ready'
        Preview      = $null
    })
}