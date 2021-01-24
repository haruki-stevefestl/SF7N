<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>

# Variables
$csvLocation = "$PSScriptRoot\S4 Interface - Tag.Current.csv"
$previewLocation = 'S:\PNG\'

# Remove & Import WPF control modules
if (Get-Module 'SF7N-GUI') {
    Remove-Module 'SF7N-Functions'
    Remove-Module 'SF7N-GUI'
}

Import-Module "$PSScriptRoot\SF7N-Functions.ps1"

# Load a WPF GUI from a XAML file build with Visual Studio
Add-Type -AssemblyName PresentationFramework, PresentationCore
$wpf = @{}
$inputXML = Get-Content -Path "$PSScriptRoot\SF7N-GUI.xaml"

$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
[Xml] $xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}

# Get the form name to be used as parameter in functions external to form.
$formName = $NamedNodes[0].Name

# Loaded in RAM events    $wpf.$formName.Add_Loaded({})
# Rendered events         $wpf.$formName.Add_ContentRendered({})
# Closing events          $wpf.$formName.Add_Closing({})

# More initalization work
Update-CSV
Import-Configuration

Import-Module "$PSScriptRoot\SF7N-GUI.ps1"

$wpf.CSVGrid.ItemsSource = $csv


# Load the form:
# Older way >>>>> $wpf.MyformName.ShowDialog() | Out-Null >>>>> generates crash if run multiple times
# Newer way >>>>> avoiding crashes after a couple of launches in PowerShell...
# Using method from https://gist.github.com/altrive/6227237 to avoid crashing Powershell after we re-run the script after some inactivity time or if we run it several times consecutively...
$async = $wpf.$formName.Dispatcher.InvokeAsync({
    $wpf.$formName.ShowDialog() | Out-Null
})
$async.Wait() | Out-Null
