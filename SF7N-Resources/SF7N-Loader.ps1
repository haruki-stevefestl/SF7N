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

Import-Configuration

# Load a WPF GUI from a XAML file
Write-Log 'INF' 'Import XAML'
Import-Module '.\Functions\F-XAML.ps1'
$wpf = Get-XAML
 
# Import GUI Control code
Write-Log 'INF' 'Import GUI Modules'
('.\Functions\F-Edit.ps1', '.\Functions\F-Search.ps1',
 '.\Handlers\H-Edit.ps1', '.\Handlers\H-Config.ps1',
 '.\Handlers\H-Search.ps1').ForEach({
     Write-Log 'INF' "    - $($_ -Replace '^.+\\','')"
     Import-Module $_ -Force
 })

# Initialzation work after splashscreen show
$wpf.SF7N.Add_ContentRendered({
    Write-Log 'INF' 'Import WinForms'
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing 

    Initialize-SF7N
})

# Prompt and cleanup on close
$wpf.SF7N.Add_Closing({
    if ($wpf.Commit.IsEnabled) {
        $Dialog = New-SaveDialog
        if ($Dialog -eq 'Cancel') {
            $_.Cancel = $true
        } elseif ($Dialog -eq 'Yes') {
            Export-CustomCSV $context.csvLocation
        }
    }

    if (!$_.Cancel) {Remove-Module 'F-*', 'H-*' -Force}
})

# Load WPF
Write-Log 'DBG' 'Launch GUI'
Write-Log 'DBG' ''
[Void] $wpf.SF7N.ShowDialog()
