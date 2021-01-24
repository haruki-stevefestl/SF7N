function Update-GUI {
    $wpf.$formName.Dispatcher.Invoke("Render",[action][scriptblock]{})
}

function Write-Log ($Location, $Type, $Message) {
    Write-Host "[$(Get-Date -Format HH:mm:ss.fff)][$Location][$Type][$Message]"
}

function Update-CSV ($ImportFrom) {
    <#
        Creates following variables:
        - csvRaw       [AList] String content from CSV
        - csv          [AList] Actual datalogging content (line 9~)
        - csvAlias     [AList] Aliases stored in CSV (line 1~8)
        - csvSearch    [AList] Matching results in searching
        - csvHeader    [Array] Header of the CSV
    #>
    [System.Collections.ArrayList] $script:csvRaw    = [System.IO.File]::ReadAllText($csvLocation) | ConvertFrom-CSV
    [System.Collections.ArrayList] $script:csv       = $csvRaw[8..$csvRaw.Count]
    [System.Collections.ArrayList] $script:csvAlias  = $csvRaw[0..7]
    [System.Collections.ArrayList] $script:csvSearch = @()
    [Array] $script:csvHeader = ((Get-Content $csvLocation -First 1) -replace '"','') -split ','
}

function Search-CSV {
    # Initialize
    $script:csvSearch = [PSCustomObject] @{}
    $wpf.CSVGrid.ItemsSource = $csvSearch
    Update-GUI

    # Apply Input Assist
    $SearchTerms = [PSCustomObject] @{}
    if ($wpf.InputAssist.IsChecked) {
        $csvHeader.foreach({ 
            $SearchTerms | Add-Member $_ (
                $wpf.$("TextBox_$_").Text -ireplace
                    ($csvAlias[1].$_, $csvAlias[0].$_) -ireplace
                    ($csvAlias[3].$_, $csvAlias[2].$_) -ireplace
                    ($csvAlias[5].$_, $csvAlias[4].$_)
            )
        })
    } else {
        $csvHeader.foreach({
            $SearchTerms | Add-Member $_ $wpf.$("TextBox_$_").Text
        })
    }
    
    # Search
    $csv.Where({
        $_.ID        -match $SearchTerms.ID        -and
        $_.Viewpoint -match $SearchTerms.Viewpoint -and
        $_.Location  -match $SearchTerms.Location  -and
        $_.Collar    -match $SearchTerms.Collar    -and
        $_.Tie       -match $SearchTerms.Tie       -and
        $_.Skirt     -match $SearchTerms.Skirt     -and
        $_.Uniform   -match $SearchTerms.Uniform   -and
        $_.Sleeve    -match $SearchTerms.Sleeve    -and
        $_.NSFW      -match $SearchTerms.NSFW      -and
        $_.Mood      -match $SearchTerms.Mood      -and
        $_.Subject   -match $SearchTerms.Subject   -and
        $_.Gender    -match $SearchTerms.Gender    -and
        $_.Time      -match $SearchTerms.Time      -and
        $_.Author    -match $SearchTerms.Author    -and
        $_.Remarks   -match $SearchTerms.Remarks
    }).Foreach{
        # Apply alias if AliasMode is on; else add raw content
        if ($wpf.AliasMode.IsChecked) {
            $tempRow = $_.PsObject.Copy()
            $tempRow.NSFW   = ($_.NSFW   -replace $csvAlias[0].NSFW,$csvAlias[1].NSFW -replace $csvAlias[2].NSFW,$csvAlias[3].NSFW -replace $csvAlias[4].NSFW,$csvAlias[5].NSFW)
            $tempRow.Mood   = ($_.Mood   -replace $csvAlias[0].Mood,$csvAlias[1].Mood -replace $csvAlias[2].Mood,$csvAlias[3].Mood -replace $csvAlias[4].Mood,$csvAlias[5].Mood)
            $tempRow.Time   = ($_.Time   -replace $csvAlias[0].Time,$csvAlias[1].Time -replace $csvAlias[2].Time,$csvAlias[3].Time -replace $csvAlias[4].Time,$csvAlias[5].Time)
            $tempRow.Sleeve = ($_.Sleeve -replace $csvAlias[0].Sleeve,$csvAlias[1].Sleeve -replace $csvAlias[2].Sleeve,$csvAlias[3].Sleeve)
            $tempRow.Gender = ($_.Gender -replace $csvAlias[0].Gender,$csvAlias[1].Gender -replace $csvAlias[2].Gender,$csvAlias[3].Gender)
            $script:csvSearch.Add($tempRow)
        } else {
            $script:csvSearch.Add($_)
        }
    }
}

function Import-Configuration {
    $script:configuration = Get-Content "$PSScriptRoot\SF7N-Configuration.ini" |
        Select-Object -Skip 1 |
            ConvertFrom-StringData
}

function Export-Configuration {
    '[SF7N-Configuration]' | Set-Content "$PSScriptRoot\SF7N-Configuration.ini"
    $configuration.GetEnumerator().ForEach({
        "$($_.Keys)=$($_.Values)" |
            Add-Content "$PSScriptRoot\SF7N-Configuration.ini"
    })
}

function Invoke-ChangeRow {
    param (
        [ValidateSet('InsertBelow', 'InsertAbove', 'InsertLast', 'RemoveAt')]
        [String] $Type,
        [Int] $At,
        [Int] $Count,
        [Boolean] $IDNeeded

    )
}
