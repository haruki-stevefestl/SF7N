function Update-GUI {
    $wpf.$formName.Dispatcher.Invoke("Render",[action][scriptblock]{})
}

function Write-Log ($Location, $Type, $Message) {
    Write-Host "[$(Get-Date -Format HH:mm:ss.fff)][$Location][$Type][$Message]"
}

function Update-CSV ($ImportFrom) {
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

    # Input Assist
    $global:SearchTerms = [PSCustomObject] @{}
    if ($wpf.InputAssist.IsChecked) {
        $csvHeader.foreach({ 
            $global:SearchTerms | Add-Member $_ (
                $wpf.$("TextBox_$_").Text -ireplace
                    ($csvAlias[1].$_, $csvAlias[0].$_) -ireplace
                    ($csvAlias[3].$_, $csvAlias[2].$_) -ireplace
                    ($csvAlias[5].$_, $csvAlias[4].$_)
            )
        })
    } else {
        $csvHeader.foreach({
            $global:SearchTerms | Add-Member $_ $wpf.$("TextBox_$_").Text
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
        if ($wpf.AliasMode.IsChecked) {
            $script:csvSearch.Add([PSCustomObject] @{
                ID        =  $_.ID
                Viewpoint =  $_.Viewpoint
                Location  =  $_.Location
                Collar    =  $_.Collar
                Tie       =  $_.Tie
                Skirt     =  $_.Skirt
                Uniform   =  $_.Uniform
                Subject   =  $_.Subject
                Author    =  $_.Author
                Remarks   =  $_.Remarks
                NSFW      = ($_.NSFW    -replace $csvAlias[0].NSFW,$csvAlias[1].NSFW -replace $csvAlias[2].NSFW,$csvAlias[3].NSFW -replace $csvAlias[4].NSFW,$csvAlias[5].NSFW)
                Mood      = ($_.Mood    -replace $csvAlias[0].Mood,$csvAlias[1].Mood -replace $csvAlias[2].Mood,$csvAlias[3].Mood -replace $csvAlias[4].Mood,$csvAlias[5].Mood)
                Time      = ($_.Time    -replace $csvAlias[0].Time,$csvAlias[1].Time -replace $csvAlias[2].Time,$csvAlias[3].Time -replace $csvAlias[4].Time,$csvAlias[5].Time)
                Sleeve    = ($_.Sleeve  -replace $csvAlias[0].Sleeve,$csvAlias[1].Sleeve -replace $csvAlias[2].Sleeve,$csvAlias[3].Sleeve)
                Gender    = ($_.Gender  -replace $csvAlias[0].Gender,$csvAlias[1].Gender -replace $csvAlias[2].Gender,$csvAlias[3].Gender)
            })
        } else {
            $script:csvSearch.Add($_)
        }
    }
}

function Invoke-ChangeRow {}

function Export-Configuration {}

function Import-Configuration {}

