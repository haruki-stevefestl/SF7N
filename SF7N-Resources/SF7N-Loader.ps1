# Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
# Used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Import the base fuction & Initialize
$startTime = Get-Date
$baseLocation = $PSScriptRoot
Set-Location $baseLocation
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
$previewLocation = $ExecutionContext.InvokeCommand.ExpandString($config.previewLocation)

# Load a WPF GUI from a XAML file
Write-Log 'INF' 'Parse  XAML'
[Xml] $xaml = Get-Content .\GUI.xaml
$tempform = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::New($xaml))
$wpf = [Hashtable]::Synchronized(@{})
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach({$wpf.Add($_, $tempform.FindName($_))})

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
    if (Test-Path $Formatting){
        $Formatting = Get-Content $Formatting | ConvertFrom-CSV
    }

    foreach ($Header in $csvHeader) {
        # Generate new column & its binding
        $NewColumn = [Windows.Controls.DataGridTextColumn]::New()
        $NewColumn.Binding = [Windows.Data.Binding]::New($Header)
        $NewColumn.Header  = $Header

        # Apply conditional formatting
        $NewStyle = [Windows.Style]::New()
        # Foreach Rule: (Rule.ColumnName == Header)
        $Formatting.Where({$_.ColumnName -eq $Header}).ForEach({
            # Foreach Trigger-Setter
            $i = 0
            while (!([String]::IsNullOrEmpty($_."Trigger$i"))) {
                # Append Trigger-Setter to Column
                $NewTrigger = [Windows.DataTrigger]::New()
                $NewTrigger.Binding = [Windows.Data.Binding]::New($Header)
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
    $wpf.TotalRows.Text = "Total rows: $($csv.Count), 100%"

    $wpf.AliasMode.IsChecked   = $config.AliasMode   -ieq 'true'
    $wpf.InputAssist.IsChecked = $config.InputAssist -ieq 'true'
    $wpf.ReadOnly.IsChecked    = $config.ReadOnly    -ieq 'true'
    $wpf.CSVGrid.IsReadOnly    = $wpf.ReadOnly.IsChecked
    $wpf.InsertLastCount.Text  = $config.InsertLast
    $wpf.CurrentMode.Text = 'Search Mode'
    if ($wpf.ReadOnly.IsChecked) {
        $wpf.ReadOnlyText.Text = 'Read-Only '
    } else {
        $wpf.ReadOnlyText.Text = 'Read/Write'
    }

    $wpf.TabControl.SelectedIndex = 1
    Write-Log 'DBG' "Total  $(((Get-Date)-$startTime).TotalMilliseconds) ms"
    Write-Log 'DBG'
})

# Cleanup on close
$wpf.SF7N.Add_Closing({
    $Exit = $true
    if ($wpf.Commit.IsEnabled) {
        switch (New-SaveDialog) {
            'Cancel' {$Exit = $false}
            'Yes'    {Export-CustomCSV $csvLocation}
        }
    }

    if ($Exit) {
        Write-Log 'DBG'
        Write-Log 'INF' 'Remove Modules'
        Remove-Module 'F-*'
        Remove-Module 'H-*'
    } else {
        $_.Cancel = $true
    }
})

# Load WPF >> Using method from https://gist.github.com/altrive/6227237
$wpf.SF7N.Dispatcher.InvokeAsync({$wpf.SF7N.ShowDialog()}).Wait() | Out-Null
