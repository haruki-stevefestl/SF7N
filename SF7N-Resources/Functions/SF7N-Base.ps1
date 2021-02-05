#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Show-MessageBox {
    param (
        [Parameter(Mandatory=$true)][String] $Prompt,
        [Parameter(Mandatory=$true)][String] $Button,
        [Parameter(Mandatory=$true)][String] $Image
    )
    return [System.Windows.MessageBox]::Show($Prompt,'SF7N Interface',$Button)
}

function Write-Log {
    param (
        [ValidateSet('INF','DBG','ERR')][String] $Type,
        [String] $Content
    )

    if ($Type -eq 'ERR') {Show-MessageBox $Content 'OK' 'Error'}

    # Output log to Host and Progressbar
    Write-Host "[$(Get-Date -Format 'HH:mm:ss.fff')][$Type] $Content" | Out-Host
    if ($null -ne $wpf.LoadingText) {$wpf.LoadingText.Text = $Content}
}

function Import-CustomCSV ($ImportFrom) {
    <#
        Creates following variables:
        - csvHeader    [Array] Header of the CSV
        - csv          [AList] Content from CSV
        - csvAlias     [AList] Aliases for CSV
        - csvSearch    [AList] Matching results in searching
    #>
    Write-Log 'INF' 'Import CSV'
    try {
        [Array] $script:csvHeader = ((Get-Content $ImportFrom -First 1) -replace '"','') -split ','
        [System.Collections.ArrayList] $script:csv       = [System.IO.File]::ReadAllText($ImportFrom) | ConvertFrom-CSV
        [System.Collections.ArrayList] $script:csvAlias  = Get-Content "$baseLocation\Configurations\CSVAlias.csv" | ConvertFrom-CSV
        [System.Collections.ArrayList] $script:csvSearch = @()
    } catch {Write-Log 'ERR' "Import CSV Failed: $_"}
}

# function Export-Configuration {
#     Write-Log 'INF' 'Export Configuration'
#     try {
        # Export configurations if changed
        # if (!(
        #     $configuration.AliasMode       -ieq ([String] $wpf.AliasMode.IsChecked)   -and
        #     $configuration.InputAssist     -ieq ([String] $wpf.InputAssist.IsChecked) -and
        #     $configuration.InsertLastCount -ieq ([String] $wpf.InsertLastCount.Text)
        # )) {
        #     $configuration[0] = [String] $wpf.AliasMode.IsChecked
        #     $configuration[1] = [String] $wpf.InputAssist.IsChecked
        #     $configuration[2] = $wpf.InsertLastCount.Text

            # Export them
#             '[SF7N-Configuration]' | Set-Content "$baseLocation\Configurations\Configurations.ini"
#             $configuration.GetEnumerator().ForEach({
#                 "$($_.Keys)=$($_.Values)" |
#                     Add-Content "$baseLocation\Configurations\Configurations.ini"
#             })
#         } else {
#             Write-Log 'INF' 'Export Configuration Cancelled: Settings unchanged'
#         }
#     } catch {Write-Log 'ERR' "Export Configuration Failed: $_"}
# }
