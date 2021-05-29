# Import the base fuction & Initialize
$startTime = Get-Date
Set-Location $PSScriptRoot
Get-ChildItem *.ps1 -Recurse | Unblock-File
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}
Import-Module .\Functions\F-Base.ps1

Write-Log 'INF' '-- SF7N Initialization --'
Write-Log 'INF' 'Import WPF'
Add-Type -AssemblyName PresentationFramework

# Read and evaluate path configurations
Write-Log 'INF' 'Import Configurations'
$config = Get-Content .\Configurations\General.ini | ConvertFrom-StringData
$csvLocation = $ExecutionContext.InvokeCommand.ExpandString($config.csvLocation)
$previewLocation = $ExecutionContext.InvokeCommand.ExpandString($config.previewPath)

# Load a WPF GUI from a XAML file
Write-Log 'INF' 'Parse  XAML'
[Xml] $xaml = Get-Content .\GUI.xaml
$tempform = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::New($xaml))
$wpf = [Hashtable]::Synchronized(@{})
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach{$wpf.Add($_, $tempform.FindName($_))}

# Import GUI Control code
Write-Log 'INF' 'Import Modules'
Get-ChildItem *.ps1 -Recurse -Exclude SF7N-Loader.ps1 | Import-Module

# Initialzation work after splashscreen show
$wpf.SF7N.Add_ContentRendered{
    Write-Log 'INF' 'Import WinForms'
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing 

    Import-CustomCSV $csvLocation
    $wpf.CSVGrid.ItemsSource = $csv

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

    $wpf.AliasMode.IsChecked   = $config.AliasMode   -ieq 'true'
    $wpf.InputAssist.IsChecked = $config.InputAssist -ieq 'true'
    $wpf.ReadWrite.IsChecked   = $config.ReadWrite   -ieq 'true'
    $wpf.InsertLastCount.Text  = $config.InsertLast

    $wpf.SplashScreen.Visibility = 'Hidden'
    Write-Log 'DBG' "Total  $(((Get-Date)-$startTime).TotalMilliseconds) ms"
}

# Prompt and cleanup on close
$wpf.SF7N.Add_Closing{
    if ($wpf.Commit.IsEnabled) {
        $Dialog = New-SaveDialog
        if ($Dialog -eq 'Cancel') {
            $_.Cancel = $true
        } elseif ($Dialog -eq 'Yes') {
            Export-CustomCSV $csvLocation
        }
    }

    if (!$_.Cancel) {
        Write-Log 'INF' 'Remove Modules'
        Remove-Module 'F-*', 'H-*'
    }
}

# Load WPF
Write-Log 'DBG' 'Launch GUI'
$wpf.SplashScreen.Visibility = 'Visible'
$wpf.SF7N.ShowDialog() | Out-Null
