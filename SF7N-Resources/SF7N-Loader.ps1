<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>
#—————————————————————————————————————————————————————————————————————————————+—————————————————————

# Variables
$csvLocation = "$PSScriptRoot\S4 Interface - FFCutdown.csv"
$previewLocation = 'S:\PNG\'

# Import the base fuction & Initialize
$baseLocation = Join-Path $(Get-Location) 'SF7N-Resources'
$startTime = Get-Date
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}
Import-Module "$baseLocation\Functions\Base.ps1"
Clear-Host
Write-Log 'INF' 'SF7N Startup'
Write-Log 'DBG'

# Load a WPF GUI from a XAML file
Write-Log 'INF' 'Import WPF'
Add-Type -AssemblyName PresentationFramework, PresentationCore

Write-Log 'INF' 'Read   XAML'
[Xml] $xaml =
    (Get-Content "$baseLocation\GUI.xaml") -replace 'x:Class=".*?"',''

Write-Log 'INF' 'Parse  XAML'
$reader = [System.Xml.XmlNodeReader]::New($xaml)
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$wpf = @{}
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach({$wpf.Add($_, $tempform.FindName($_))})

# Import GUI Control functions & Prepare splash screen
Write-Log 'INF' 'Import GUI control modules'
Import-Module "$baseLocation\Functions\Edit.ps1",
    "$baseLocation\Functions\Search.ps1",
    "$baseLocation\GUI.ps1"

# Initialzation work after splashscreen show
$wpf.SF7N.Add_ContentRendered({
    Write-Log 'INF' 'Build  Datagrid columns'
    $csvHeader.ForEach({
        $NewColumn = [System.Windows.Controls.DataGridTextColumn]::New()
        $NewColumn.Binding = [System.Windows.Data.Binding]::New($_)
        $NewColumn.Header  = $_
        
        ## TESTING.START - DynamicFormatting

        <#
        // TODO: Make it so each column can have multiple triggers and setters
        // Possible method:
        
        newStyle = new style
        foreach (rule in allRules) {
            thisSetter = new Setter
            thisTrigger = new Trigger
            newStyle.add(thisTrigger)
        }
        newColumn.style = newStyle

        // TODO: Implment custom format for custom datagrid rules
        // Possible method: csv

        ColumnName, [TriggerValue1, SetterValue1, [TriggerValue2, SetterValue2, ...]]
        #>

        $NewStyle  = [System.Windows.Style]::New([System.Windows.Controls.DataGridCell])

        $NewTrigger = [System.Windows.DataTrigger]::New()
        $NewTrigger.Binding = [System.Windows.Data.Binding]::New($_)
        $NewTrigger.Value = '20200406-1439'

        $NewSetter = [System.Windows.Setter]::New(
            [System.Windows.Controls.DataGridCell]::BackgroundProperty,
            [System.Windows.Media.Brushes]::Red
        )

        $NewTrigger.Setters.Add($NewSetter)
        $NewStyle.Triggers.Add($NewTrigger)
        
        $NewColumn.CellStyle = $NewStyle
        ## TESTING.END - DynamicFormatting

        $wpf.CSVGrid.Columns.Add($NewColumn)
    })

    Import-CustomCSV $csvLocation
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
$async = $wpf.SF7N.Dispatcher.InvokeAsync({$wpf.SF7N.ShowDialog() | Out-Null})
$async.Wait() | Out-Null
