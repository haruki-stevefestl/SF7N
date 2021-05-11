# Import the base fuction & Initialize
$startTime = Get-Date
Set-Location $PSScriptRoot
Get-ChildItem *.ps1 -Recurse | Unblock-File
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}
Import-Module .\Functions\F-Base.ps1

Clear-Host
Write-Log 'INF' '-- SF7N Initialization --'
Write-Log 'INF' 'Import WPF'
Add-Type -AssemblyName PresentationFramework, PresentationCore

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
$ErrorActionPreference = 'SilentlyContinue'
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach({$wpf.Add($_, $tempform.FindName($_))})
$ErrorActionPreference = 'Continue'

# Import GUI Control code
Write-Log 'INF' 'Import Modules'
Get-ChildItem *.ps1 -Recurse -Exclude SF7N-Loader.ps1 | Import-Module

# Initialzation work after splashscreen show
$wpf.SF7N.Add_ContentRendered({
    Write-Log 'DBG' 'Launch GUI'
    Write-Log 'DBG'
    Write-Log 'INF' 'Import WinForms'
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing 

    Import-CustomCSV $csvLocation
    $wpf.CSVGrid.ItemsSource = $csv

    # Generate columns of Datagrid
    Write-Log 'INF' 'Build  Datagrid'
    $Formatting = '.\Configurations\Formatting.csv'
    if (Test-Path $Formatting) {$Formatting = Import-CSV $Formatting}

    foreach ($Header in $csvHeader) {
        # Generate new column & its binding
        $NewColumn = [Windows.Controls.DataGridTextColumn]::New()
        $NewColumn.Binding = [Windows.Data.Binding]::New($Header)
        $NewColumn.Header  = $Header
    
        # Apply conditional formatting
        $NewStyle = [Windows.Style]::New()

        # Foreach Trigger-Setter
        $Formatting.Where{$_.ColumnName -eq $Header}.ForEach({
            $i = 0
            while ($_."Trigger$i" -notMatch '^\s*$') {
                # Append Trigger-Setter to Column
                $NewTrigger = [Windows.DataTrigger]::New()
                $NewTrigger.Binding = $NewColumn.Binding
                $NewTrigger.Value = $_."Trigger$i"
                $NewTrigger.Setters.Add([Windows.Setter]::New(
                    [Windows.Controls.DataGridCell]::BackgroundProperty,
                    [Windows.Media.BrushConverter]::New().ConvertFromString($_."Setter$i")
                ))
                $NewStyle.Triggers.Add($NewTrigger)
                ++ $i
            }
        })
        $NewColumn.CellStyle = $NewStyle
        $wpf.CSVGrid.Columns.Add($NewColumn)
    }
    $wpf.AliasMode.IsChecked   = $config.AliasMode   -ieq 'true'
    $wpf.InputAssist.IsChecked = $config.InputAssist -ieq 'true'
    $wpf.ReadOnly.IsChecked    = $config.ReadOnly    -ieq 'true'
    $wpf.TabSearch.IsChecked   = $config.TabSearch   -ieq 'true'
    $wpf.InsertLastCount.Text  = $config.InsertLast

    Write-Log 'DBG' "Total  $(((Get-Date)-$startTime).TotalMilliseconds) ms"
    Write-Log 'DBG'
})

# Prompt and cleanup on close
$wpf.SF7N.Add_Closing({
    if ($wpf.Commit.IsEnabled) {
        $Dialog = New-SaveDialog
        if ($Dialog -eq 'Cancel') {
            $_.Cancel = $true
        } elseif ($Dialog -eq 'Yes') {
            Export-CustomCSV $csvLocation
        }
    }

    if (!$_.Cancel) {
        Write-Log 'DBG'
        Write-Log 'INF' 'Remove Modules'
        Remove-Module 'F-*', 'H-*'
    }
})

# Load WPF
$wpf.SF7N.ShowDialog() | Out-Null
