<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>
#—————————————————————————————————————————————————————————————————————————————+—————————————————————

# Variables
$csvLocation = "$PSScriptRoot\S4 Interface - FFCutdown.csv"
$previewLocation = 'S:\PNG\'

# Import basic functions
$startTime = Get-Date
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}
Import-Module "$PSScriptRoot\SF7N-Functions.ps1"
Clear-Host
Write-Log 'INF' 'SF7N Startup'
Write-Log 'DBG'

# Load a WPF GUI from a XAML file
Write-Log 'INF' 'Import WPF'
Add-Type -AssemblyName PresentationFramework, PresentationCore

Write-Log 'INF' 'Read   XAML'
$inputXML = Get-Content -Path "$PSScriptRoot\SF7N-GUI.xaml"

Write-Log 'INF' 'Parse  XAML'
[Xml] $xaml = $inputXML -replace 'x:Class=".*?"','' -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
$reader = [System.Xml.XmlNodeReader]::New($xaml)
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$wpf = @{}
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes.Name.ForEach({$wpf.Add($_, $tempform.FindName($_))})

# Import GUI Control functions & Prepare splash screen
Write-Log 'INF' 'Import GUI control modules'
Import-Module "$PSScriptRoot\SF7N-Functions-Edit.ps1"
Import-Module "$PSScriptRoot\SF7N-Functions-Search.ps1"
Import-Module "$PSScriptRoot\SF7N-GUI.ps1"

# Initialzation work after splashscreen show
$wpf.SF7N.Add_ContentRendered({
    Write-Log 'INF' 'Build  Datagrid columns'
    $csvHeader.ForEach({
        $NewColumn = [System.Windows.Controls.DataGridTextColumn]::New()
        $NewColumn.Binding = [System.Windows.Data.Binding]::New($_)
        $NewColumn.Header  = $_
        $wpf.CSVGrid.Columns.Add($NewColumn)
    })

    Import-CustomCSV $csvLocation
    $wpf.TotalRows.Text = "Total rows: $($csv.Count)"
    Import-Configuration

    $wpf.TabControl.SelectedIndex = 1
    Write-Log 'DBG' "Startup: $(((Get-Date) - $startTime).TotalMilliseconds) ms"
    Write-Log 'DBG'
})

# Cleanup on close
$wpf.SF7N.Add_Closing({
    Write-Log 'DBG'
    Write-Log 'INF' 'Remove Modules'
    Remove-Module 'SF7N-*'
    # // Get-Module "SF7N-*" | Remove-Module // also works
    # Write-Log 'INF' 'Remove Variables'
    # Remove-Variable * -ErrorAction SilentlyContinue
})

# Load WPF Form:
# Old way >> .ShowDialog() | Out-Null >> crashes if run multiple times
# New way >> Using method from https://gist.github.com/altrive/6227237
$async = $wpf.SF7N.Dispatcher.InvokeAsync({$wpf.SF7N.ShowDialog() | Out-Null})
$async.Wait() | Out-Null
