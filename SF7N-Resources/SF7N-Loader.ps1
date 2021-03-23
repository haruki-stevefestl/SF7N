<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Import the base fuction & Initialize
$startTime = Get-Date
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}

Import-Module "$PSScriptRoot\Functions\SF7N-Base.ps1"
Clear-Host
Write-Log 'INF' 'SF7N Startup'
Write-Log 'DBG'

Write-Log 'INF' 'Import WPF'
Add-Type -AssemblyName PresentationFramework, PresentationCore
Write-Log 'INF' 'Import WinForms'
Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Read and evaluate path configurations
$configuration = Import-Configuration "$PSScriptRoot\Configurations\Configurations-Base.ini"
$configuration.GetEnumerator().ForEach({
    Set-Variable $_.Keys $($ExecutionContext.InvokeCommand.ExpandString($_.Values))
})

# Load a WPF GUI from a XAML file
Write-Log 'INF' 'Parse  XAML'
[Xml] $xaml = Get-Content "$PSScriptRoot\GUI.xaml"
$tempform = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::New($xaml))
$wpf = @{}
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach({$wpf.Add($_, $tempform.FindName($_))})

# Import GUI Control functions & Prepare splash screen
Write-Log 'INF' 'Import GUI Control Modules'
Import-Module "$PSScriptRoot\Functions\SF7N-UX.ps1",
    "$PSScriptRoot\Functions\SF7N-Edit.ps1",
    "$PSScriptRoot\Functions\SF7N-Search.ps1",
    "$PSScriptRoot\SF7N-GUI.ps1"

# Initialzation work after splashscreen show
$wpf.SF7N.Add_ContentRendered({
    Import-CustomCSV $csvLocation
    $wpf.CSVGrid.ItemsSource = $csv

    # Generate columns of Datagrid
    Write-Log 'INF' 'Build  Datagrid Columns'
    $FormattingLocation = "$PSScriptRoot\Configurations\ConditionalFormatting.csv"
    if (Test-Path $FormattingLocation) {
        $Formatting = Get-Content $FormattingLocation | ConvertFrom-CSV
    }

    foreach ($Header in $csvHeader) {
        # Generate new column & its binding
        $NewColumn = [Windows.Controls.DataGridTextColumn]::New()
        $NewColumn.Binding = [Windows.Data.Binding]::New($Header)
        $NewColumn.Header  = $Header

        # Apply conditional formatting
        $NewStyle = [Windows.Style]::New()
        # Foreach Rule: (Rule.ColumnName = Header)
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

    $wpf.TotalRows.Text = "Total rows: $($csv.Count)"

    $script:configuration = Import-Configuration "$PSScriptRoot\Configurations\Configurations-GUI.ini"
    $wpf.AliasMode.IsChecked   = $configuration.AliasMode   -ieq 'true'
    $wpf.InputAssist.IsChecked = $configuration.InputAssist -ieq 'true'
    $wpf.ReadOnly.IsChecked    = $configuration.ReadOnly    -ieq 'true'
    $wpf.CSVGrid.IsReadOnly    = $wpf.ReadOnly.IsChecked
    $wpf.InsertLastCount.Text  = $configuration.InsertLast
    $wpf.CurrentMode.Text = 'Search Mode'
    if ($wpf.ReadOnly.IsChecked) {$wpf.CurrentMode.Text += ' (Read-only)'}

    $wpf.TabControl.SelectedIndex = 1
    Write-Log 'DBG' "$(((Get-Date) - $startTime).TotalMilliseconds) ms elpased"
    Write-Log 'DBG'
})

# Cleanup on close
$wpf.SF7N.Add_Closing({
    if ($wpf.Commit.IsEnabled) {
        $SavePrompt = [Windows.MessageBox]::Show(
            'Would you like to commit unsaved changes before exiting?',
            'SF7N Interface',
            3
        )

        if ($SavePrompt -eq 'Cancel') {
            $_.Cancel = $true
        } elseif ($SavePrompt -eq 'Yes') {
            Export-CustomCSV $csvLocation
        }
    }

    if (!$_.Cancel) {
        Write-Log 'DBG'
        Write-Log 'INF' 'Remove Modules'
        Remove-Module 'SF7N-*'
    }
})

# Load WPF >> Using method from https://gist.github.com/altrive/6227237
$wpf.SF7N.Dispatcher.InvokeAsync({$wpf.SF7N.ShowDialog()}).Wait() | Out-Null
