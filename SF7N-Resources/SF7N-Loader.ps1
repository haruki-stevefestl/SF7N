<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Variables
$csvLocation = "$PSScriptRoot\CSVData\shinkansen.csv"
$script:previewLocation  = 'T:\SF7N\SF7N-Resources\CSVData\'
$script:previewColumn    = 'Train'
$script:previewExtension = '.png'

# Import the base fuction & Initialize
$startTime = Get-Date
$baseLocation = Get-Location
if (Test-path "$baseLocation\SF7N-Resources") {
	$baseLocation = Join-Path $baseLocation 'SF7N-Resources'
}
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}
Import-Module "$baseLocation\Functions\SF7N-Base.ps1"
Clear-Host
Write-Log 'INF' 'SF7N Startup'
Write-Log 'DBG'

# Load a WPF GUI from a XAML file
Write-Log 'INF' 'Import WPF'
Add-Type -AssemblyName PresentationFramework, PresentationCore

Write-Log 'INF' 'Read   XAML'
[Xml] $xaml = Get-Content "$baseLocation\GUI.xaml"

Write-Log 'INF' 'Parse  XAML'
$reader = [System.Xml.XmlNodeReader]::New($xaml)
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$wpf = @{}
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach({$wpf.Add($_, $tempform.FindName($_))})

# Import GUI Control functions & Prepare splash screen
Write-Log 'INF' 'Import GUI control modules'
Import-Module "$baseLocation\Functions\SF7N-Edit.ps1",
    "$baseLocation\Functions\SF7N-Search.ps1",
    "$baseLocation\SF7N-GUI.ps1"

# Initialzation work after splashscreen show
$wpf.SF7N.Add_ContentRendered({
    Import-CustomCSV $csvLocation
    $wpf.CSVGrid.ItemsSource = $csv

    Write-Log 'INF' 'Build  Datagrid columns'
    $Formatting = Get-Content "$baseLocation\Configurations\ConditionalFormatting.csv" | ConvertFrom-CSV
    
    foreach ($Header in $csvHeader) {
        # Generate new column
        $NewColumn = [System.Windows.Controls.DataGridTextColumn]::New()
        $NewColumn.Binding = [System.Windows.Data.Binding]::New($Header)
        $NewColumn.Header  = $Header
        
        # Apply conditional formatting
        $NewStyle = [System.Windows.Style]::New()
        # Foreach Rule: (Rule.ColumnName = Header)
        $Formatting.Where({$_.ColumnName -eq $Header}).ForEach({
            # Foreach Trigger-Setter
            $i = 0
            while (!([String]::IsNullOrEmpty($_."Trigger$i"))) {
                # Append Rule to Column
                $NewTrigger = [System.Windows.DataTrigger]::New()
                $NewTrigger.Binding = [System.Windows.Data.Binding]::New($Header)
                $NewTrigger.Value = $_."Trigger$i"

                $NewSetter = [System.Windows.Setter]::New(
                    [System.Windows.Controls.DataGridCell]::BackgroundProperty,
                    [System.Windows.Media.BrushConverter]::New().ConvertFromString($_."Setter$i")
                )

                $NewTrigger.Setters.Add($NewSetter)
                $NewStyle.Triggers.Add($NewTrigger)
                ++ $i
            }
        })
        $NewColumn.CellStyle = $NewStyle
        $wpf.CSVGrid.Columns.Add($NewColumn)
    }

    $wpf.TotalRows.Text = "Total rows: $($csv.Count)"
    Import-Configuration "$baseLocation\Configurations\Configurations.ini"

    $wpf.TabControl.SelectedIndex = 1
    Write-Log 'DBG' "$(((Get-Date) - $startTime).TotalMilliseconds) ms elpased"
    Write-Log 'DBG'
})

# Cleanup on close
$wpf.SF7N.Add_Closing({
    Write-Log 'DBG'
    Write-Log 'INF' 'Remove Modules'
    Remove-Module 'SF7N-*'
})

# Load WPF >> Using method from https://gist.github.com/altrive/6227237
$wpf.SF7N.Dispatcher.InvokeAsync({$wpf.SF7N.ShowDialog()}).Wait() | Out-Null
