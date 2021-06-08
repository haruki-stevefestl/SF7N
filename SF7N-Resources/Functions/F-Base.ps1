function Write-Log ($Type, $Content) {
    if ($Type -eq 'ERR') {
        [Windows.MessageBox]::Show($Content, 'SF7N Interface', 'OK', 'Error') | Out-Null
    }
    Write-Host "[$(Get-Date -Format HH:mm:ss.fff)][$Type] $Content" | Out-Host
}

function Import-CustomCSV ($ImportFrom) {
    <#
        Creates following variables:
        - csvHeader    [Array] Header of the CSV
        - csv          [AList] Content from CSV
        - csvAlias     [AList] Aliases for CSV
    #>
    Write-Log 'INF' 'Import CSV'
    try {
        $script:csvHeader = (Get-Content $ImportFrom -First 1) -replace '"','' -split ','
        [Collections.ArrayList] $script:csv = Import-CSV $ImportFrom
        
        $AliasLocation = '.\Configurations\CSVAlias.csv'
        if (Test-Path $AliasLocation) {
            [Collections.ArrayList] $script:csvAlias = Import-CSV $AliasLocation
        }
    } catch {Write-Log 'ERR' "Import CSV Failed: $_"}

    # Enter edit mode if CSV is empty
    if (!$csvHeader) {
        Write-Log 'ERR' 'CSV is empty; SF7N will exit.'
        $wpf.SF7N.Close()

    } elseif (!$csv) {
        $wpf.Toolbar.SelectedIndex = 1
    }
}

function New-SaveDialog {
    [Windows.MessageBox]::Show('Commit changes before exiting?', 'SF7N Interface', 'YesNoCancel', 'Question')
}

function Invoke-Initialization {
    Import-CustomCSV $csvLocation
    $wpf.CSVGrid.ItemsSource = $null
    $wpf.CSVGrid.Columns.Clear()
    
    # Generate columns of Datagrid
    Write-Log 'INF' 'Build  Datagrid'
    $Format = '.\Configurations\Formatting.csv'
    if (Test-Path $Format) {$Format = Import-CSV $Format}

    $csvHeader.ForEach{
        $Column = [Windows.Controls.DataGridTextColumn]::New()
        $Column.Binding = [Windows.Data.Binding]::New($_)
        $Column.Header  = $_
        $Column.CellStyle = [Windows.Style]::New()

        # Apply conditional formatting
        for ($i = 0; $i -lt $Format.$_.Count; $i += 2) {
            if ([String]::IsNullOrWhiteSpace($Format.$_[$i])) {break}
            $Trigger = [Windows.DataTrigger]::New()
            $Trigger.Binding = $Column.Binding
            $Trigger.Value = $Format.$_[$i]
            $Trigger.Setters.Add([Windows.Setter]::New(
                [Windows.Controls.DataGridCell]::BackgroundProperty,
                [Windows.Media.BrushConverter]::New().ConvertFromString($Format.$_[$i+1])
            ))
            $Column.CellStyle.Triggers.Add($Trigger)
        }
        $wpf.CSVGrid.Columns.Add($Column)
    }
    Search-CSV $wpf.SearchBar.Text

    # Cleanup
    $wpf.SplashScreen.Visibility = 'Hidden'
}
