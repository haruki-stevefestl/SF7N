# Import the base fuction & Initialize
$script:startTime = Get-Date
$script:baseLocation = $PSScriptRoot
Set-Location $PSScriptRoot
Get-ChildItem *.ps1 -Recurse | Unblock-File
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}
Import-Module .\Functions\F-Base.ps1

Write-Log 'INF' '-- SF7N Initialization --'
Write-Log 'INF' 'Import WPF'
Add-Type -AssemblyName PresentationFramework


# Read and evaluate path configurations
Write-Log 'INF' 'Import Configurations'
$script:config = Get-Content .\Configurations\General.ini | ConvertFrom-StringData


# Load a WPF GUI from a XAML file
Write-Log 'INF' 'Parse  XAML'
$tempXaml = Get-Content .\GUI.xaml

Write-Log 'DBG' 'Inject theming'
$Color = [PSCustomObject] @{
    Background = '#FFFFFF'
    Caption    = '#696969'
    Header     = '#EEEEEE'
    Foreground = '#000000'
    Highlight  = '#CCE8FF'
    Control    = '#E5F3FF'
    Highlight_  = @(204, 232, 255)
    Control_    = @(229, 243, 255)
    Foreground_ = @(255, 255, 255)
}
if ($config.DarkMode -ieq 'True') {
    $Color = [PSCustomObject] @{
        Background = '#242424'
        Caption    = '#969696'
        Header     = '#404040'
        Foreground = '#EEEEEE'
        Highlight  = '#3299FE'
        Control    = '#3299FE'
        Highlight_  = @(50, 153, 254)
        Control_    = @(50, 153, 254)
        Foreground_ = @(238, 238, 238)
    }
}

$tempXaml[6]  = '<SolidColorBrush x:Key="Color_Background" Color="'+ $Color.Background +'"/>'
$tempXaml[7]  = '<SolidColorBrush x:Key="Color_Caption"    Color="'+ $Color.Caption    +'"/>'
$tempXaml[8]  = '<SolidColorBrush x:Key="Color_Header"     Color="'+ $Color.Header     +'"/>'
$tempXaml[9]  = '<SolidColorBrush x:Key="Color_Foreground" Color="'+ $Color.Foreground +'"/>'
$tempXaml[10] = '<SolidColorBrush x:Key="Color_Highlight"  Color="'+ $Color.Highlight  +'"/>'
$tempXaml[11] = '<SolidColorBrush x:Key="Color_Control"    Color="'+ $Color.Control    +'"/>'
$tempXaml[12] = '<Color x:Key="Color__Highlight" R="'+ $Color.Highlight_[0]  +'" G="'+ $Color.Highlight_[1]  +'" B="'+ $Color.Highlight_[2]  +'" A="255"/>'
$tempXaml[13] = '<Color x:Key="Color__Control"    R="'+ $Color.Control_[0]    +'" G="'+ $Color.Control_[1]    +'" B="'+ $Color.Control_[2]    +'" A="255"/>'
$tempXaml[14] = '<Color x:Key="Color__Foreground" R="'+ $Color.Foreground_[0] +'" G="'+ $Color.Foreground_[1] +'" B="'+ $Color.Foreground_[2] +'" A="255"/>'

[Xml] $xaml = $tempXaml
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
$wpf.SF7N.Add_ContentRendered({
    Write-Log 'INF' 'Import WinForms'
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing 

    # Remove-Variable 'tempform', 'xaml', 'tempXaml', 'Color' -Scope Script
    Initialize-SF7N
})


# Prompt and cleanup on close
$wpf.SF7N.Add_Closing({
    if ($wpf.Commit.IsEnabled) {
        $Dialog = New-SaveDialog
        if ($Dialog -eq 'Cancel') {
            $_.Cancel = $true
        } elseif ($Dialog -eq 'Yes') {
            Export-CustomCSV $dataContext.csvLocation
        }
    }

    if (!$_.Cancel) {Remove-Module 'F-*', 'H-*'}
})


# Load WPF
Write-Log 'DBG' 'Launch GUI'
$wpf.SF7N.ShowDialog() | Out-Null
