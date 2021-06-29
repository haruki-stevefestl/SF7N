#Requires -Version 3
# Base variables & functions
$script:startTime    = Get-Date
$script:baseLocation = $PSScriptRoot
Set-Location $PSScriptRoot

function Write-Log ($Log, [Boolean] $IsError) {
    $TimeDiff = ((Get-Date)-$startTime).TotalMilliseconds
    Write-Output ("{0,-8:0}  {1}" -F $TimeDiff,$Log) | Out-Host

    if ($IsError) {
        [Void][Windows.MessageBox]::Show($Log, 'SF7N', 'OK', 'Error')
    }
}

Write-Log 'SF7N 1.7'
Write-Log '-------------------------'

# Defaults for SF7N
Write-Log 'Set    Defaults Parameters'
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}
Set-Location $PSScriptRoot\Functions
Unblock-File DataContext.ps1, DataIO.ps1, Edit.ps1,
             Initialize.ps1, Search.ps1, XAML.ps1
Set-Location $PSScriptRoot\Handlers
Unblock-File Config.ps1, Edit.ps1, Lifecycle.ps1, Search.ps1
Set-Location $PSScriptRoot

# Configurations & DataContext
Import-Module .\Functions\DataContext.ps1 -Force
$script:config  = Import-Configuration .\Configurations\General.ini
$script:context = New-DataContext $config

# XAML & GUI
Import-Module .\Functions\XAML.ps1 -Force
$script:wpf = New-GUI .\GUI.xaml

# GUI Functions
Write-Log 'Import GUI Functions'
foreach ($Function in 'DataIO','Search','Edit') {
    Write-Log ('  - '+$Function)
    Import-Module ".\Functions\$Function.ps1" -Force
}

# GUI Handlers
Write-Log 'Import GUI Handlers'
foreach ($Handler in 'Search','Edit','Config') {
    Write-Log ('  - '+$Handler)
    Import-Module ".\Handlers\$Handler.ps1" -Force
}
Remove-Variable Function, Handler

# Lifecycle Handlers
Write-Log 'Import Lifecycle Handlers'
Import-Module .\Handlers\Lifecycle.ps1 -Force

# Display GUI
Write-Log '-------------------------'
[Void] $wpf.SF7N.ShowDialog()
