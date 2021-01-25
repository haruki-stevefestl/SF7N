#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Update-GUI {
    $wpf.$formName.Dispatcher.Invoke("Render",[action][scriptblock]{})
}

function Show-MessageBox {
    param (
        [Parameter(Mandatory=$true)] $Title,
        [Parameter(Mandatory=$true)] $Message,
        [Parameter(Mandatory=$true)] $Button,
        [Parameter(Mandatory=$false)] $Image
    )
    $MessageBox =
        if ($null -ne $Image) {
            [System.Windows.MessageBox]::Show($Message,$Title,$Button,$Image)
        } else {
            [System.Windows.MessageBox]::Show($Message,$Title,$Button)
        }

    return $MessageBox
}

function Write-Log {
    param (
        [ValidateSet('INF','DBG','ERR')] $Type,
        $Log
    )
    if ($Type -eq 'ERR') {Show-MessageBox 'Error' $Log 'OK' 'Error'}
    Write-Host "[$(Get-Date -Format HH:mm:ss.fff)][$Type] $Log"
}

function Import-CustomCSV ($ImportFrom) {
    <#
        Creates following variables:
        - csvRaw       [AList] String content from CSV
        - csv          [AList] Actual datalogging content (line 9~)
        - csvAlias     [AList] Aliases stored in CSV (line 1~8)
        - csvSearch    [AList] Matching results in searching
        - csvHeader    [Array] Header of the CSV
    #>
    Write-Log 'INF' 'Import CSV'
    try {
        [Array] $script:csvHeader = ((Get-Content $csvLocation -First 1) -replace '"','') -split ','
        [System.Collections.ArrayList] $script:csvRaw    = [System.IO.File]::ReadAllText($csvLocation) | ConvertFrom-CSV
        [System.Collections.ArrayList] $script:csv       = $csvRaw[9..$csvRaw.Count]
        [System.Collections.ArrayList] $script:csvAlias  = $csvRaw[1..8]
        [System.Collections.ArrayList] $script:csvSearch = @()
    } catch {Write-Log 'ERR' 'Import CSV Failed'}
}


function Set-Preview ($InputObject) {
    $InputObject = "S:\PNG\$($InputObject).png"
    if (($null -ne $InputObject) -and (Test-Path $InputObject)) {
        $wpf.Preview.Source = $InputObject
    }
}

function Import-Configuration {
    Write-Log 'INF' 'Import Configuration'
    try {
        # Retrieve configurations from .ini
        $script:configuration = Get-Content "$PSScriptRoot\SF7N-Configuration.ini" |
            Select-Object -Skip 1 |
                ConvertFrom-StringData

        # Apply them
        $wpf.AliasMode.IsChecked   = $configuration.AliasMode   -eq 'true'
        $wpf.InputAssist.IsChecked = $configuration.InputAssist -eq 'true'
        $wpf.InsertLastCount.Text  = $configuration.InsertLastCount
    } catch {Write-Log 'ERR' 'Import Configuration Failed'}
}

function Export-Configuration {
    Write-Log 'INF' 'Export Configuration'
    try {
        # Retrieve configurations from UI
        $configuration.AliasMode       = $wpf.AliasMode.IsChecked
        $configuration.InputAssist     = $wpf.InputAssist.IsChecked
        $configuration.InsertLastCount = $wpf.InsertLastCount.Text

        # Export them
        '[SF7N-Configuration]' | Set-Content "$PSScriptRoot\SF7N-Configuration.ini"
        $configuration.GetEnumerator().ForEach({
            "$($_.Keys)=$($_.Values)" |
                Add-Content "$PSScriptRoot\SF7N-Configuration.ini"
        })
    } catch {Write-Log 'ERR' 'Exoprt Configuration Failed'}
}
