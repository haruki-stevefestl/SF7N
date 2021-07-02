function Import-CustomCSV ($ImportFrom) {
    # Creates following variables:
    #   - csv        [AList] Content
    #   - csvHeader  [Array] Header of the CSV
    #   - csvAlias   [Array] Aliases for CSV
    Write-Log 'Import CSV'
    $ImportFrom = $ExecutionContext.InvokeCommand.ExpandString($ImportFrom)
    [Collections.ArrayList] $script:csv = Import-CSV $ImportFrom

    $Reader = [IO.StreamReader]::New($ImportFrom)
    $script:csvHeader = $Reader.ReadLine() -replace '"' -split ','

    $Alias = '.\Configurations\CSVAlias.csv'
    if (Test-Path $Alias) {$script:csvAlias = Import-CSV $Alias}

    # Exit if CSV is empty
    if (!$csvHeader) {
        Write-Log 'CSV is empty; SF7N will exit.' -IsError $true
        $wpf.SF7N.Close()
    }
}

function Export-CustomCSV ($ExportTo) {
    try {
        $csv | Export-CSV $ExecutionContext.InvokeCommand.ExpandString($ExportTo) -NoTypeInformation
        $wpf.Commit.IsEnabled = $false
    } catch {
        Write-Log ('CSV cannot be saved: '+$_) -IsError $true
    }
}

function New-SaveDialog {
    return [Windows.MessageBox]::Show('Commit changes before exiting?', 'SF7N', 'YesNoCancel', 'Question')
}
