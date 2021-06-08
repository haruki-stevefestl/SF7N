# Import the base fuction & Initialize
$startTime = Get-Date
Set-Location $PSScriptRoot
Get-ChildItem *.ps1 -Recurse | Unblock-File
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}
Import-Module .\Functions\F-Base.ps1

Write-Log 'INF' '-- SF7N Initialization --'
Write-Log 'INF' 'Import WPF'
Add-Type -AssemblyName PresentationFramework

# Load a WPF GUI from a XAML file
Write-Log 'INF' 'Parse  XAML'
[Xml] $xaml = Get-Content .\GUI.xaml
$tempform = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::New($xaml))
$wpf = [Hashtable]::Synchronized(@{})
$ErrorActionPreference = 'SilentlyContinue'
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach{$wpf.Add($_, $tempform.FindName($_))}
$ErrorActionPreference = 'Continue'

# Import GUI Control code
Write-Log 'INF' 'Import Modules'
Import-Module '.\Functions\F-Edit.ps1', '.\Functions\F-Search.ps1',
              '.\Handlers\H-Edit.ps1', '.\Handlers\H-Config.ps1',
              '.\Handlers\H-Search.ps1'

# Initialzation work after splashscreen show
$wpf.SF7N.Add_ContentRendered{
    Write-Log 'INF' 'Import WinForms'
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing 

    # Read and evaluate path configurations
    Write-Log 'INF' 'Import Configurations'
    $script:config = Get-Content .\Configurations\General.ini | ConvertFrom-StringData
    $script:csvLocation = $ExecutionContext.InvokeCommand.ExpandString($config.csvLocation)
    $script:previewLocation = $ExecutionContext.InvokeCommand.ExpandString($config.previewPath)

    # Apply config
    $wpf.Config_CSVLocation.Text      = $config.csvLocation
    $wpf.Config_PreviewLocation.Text  = $config.PreviewPath
    $wpf.Config_InputAssist.IsChecked = $config.InputAssist -ieq 'true'
    $wpf.Config_AppendFormat.Text     = $config.AppendFormat
    $wpf.Config_AppendCount.Text      = $config.InsertLast
    $wpf.Config_AliasMode.IsChecked   = $config.AliasMode   -ieq 'true'
    $wpf.Config_ReadWrite.IsChecked   = $config.ReadWrite   -ieq 'true'

    Invoke-Initialization

    Write-Log 'DBG' "Total  $(((Get-Date)-$startTime).TotalMilliseconds) ms"
    Remove-Variable 'tempform', 'xaml', 'startTime' -Scope Script
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
