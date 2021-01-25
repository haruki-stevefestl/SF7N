<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>

# Variables
$csvLocation = "$PSScriptRoot\S4 Interface - FFCutdown.csv"
$previewLocation = 'S:\PNG\'

# Remove & Import WPF control modules
if (Get-Module 'SF7N-GUI') {
    Remove-Module 'SF7N-Functions'
    Remove-Module 'SF7N-GUI'
}

Import-Module "$PSScriptRoot\SF7N-Functions.ps1"
Write-Log 'INF' 'SF7N Startup'
Write-Log 'DBG'

# Load a WPF GUI from a XAML file build with Visual Studio
Write-Log 'INF' 'Import WPF'
Add-Type -AssemblyName PresentationFramework, PresentationCore
$wpf = @{}

Write-Log 'INF' 'Read   XAML'
$inputXML = Get-Content -Path "$PSScriptRoot\SF7N-GUI.xaml"

Write-Log 'INF' 'Parse  XAML'
$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
[Xml] $xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}

# Get the form name to be used as parameter in functions external to form.
$formName = $NamedNodes[0].Name

# Prepare splash screen
$wpf.Splashscreen.Visibility = "Visible"

# Initialzation work after splashscreen show
$wpf.$formName.Add_ContentRendered({
    Update-CSV
    $wpf.CSVGrid.ItemsSource = $csv

    Import-Configuration
    Write-Log 'INF' 'Import GUI Control Module'
    Import-Module "$PSScriptRoot\SF7N-GUI.ps1"

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
