<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>

#—————————————————————————————————————————————————————————————————————————————+—————————————————————
Remove-Variable "*"
Remove-Module "SF7N-*"

$csvLocation = "$PSScriptRoot\S4 Interface - FFCutdown.csv"
$previewLocation = 'S:\PNG\'

# Force use of UTF-8
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

# Get form name
$formName = $namedNodes[0].Name

# Prepare splash screen
$wpf.Splashscreen.Visibility = "Visible"
Import-Module "$PSScriptRoot\SF7N-Functions-Edit.ps1"
Import-Module "$PSScriptRoot\SF7N-Functions-Search.ps1"
Import-Module "$PSScriptRoot\SF7N-GUI.ps1"

# Initialzation work after splashscreen show
$wpf.$formName.Add_ContentRendered({
    Import-CustomCSV $csvLocation
    $wpf.CSVGrid.ItemsSource = $csv

    Import-Configuration
    Write-Log 'INF' 'Import GUI Control Module'

    $wpf.Splashscreen.Visibility = "Hidden"
    Write-Log 'DBG'
})

# Load WPF Form:
# Old way >> .ShowDialog() | Out-Null >> crashes if run multiple times
# New way >> Using method from https://gist.github.com/altrive/6227237
$async = $wpf.$formName.Dispatcher.InvokeAsync({
    $wpf.$formName.ShowDialog() | Out-Null
})
$async.Wait() | Out-Null
