#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Search-CSV {
    # Initialize
    Write-Log 'INF' 'Search CSV'
    $wpf.CSVGrid.ItemsSource = $null
    $wpf.CSVGrid.Items.Clear()

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
            $wpf.CSVGrid.Items.Add($tempRow)
        } else {
            $wpf.CSVGrid.Items.Add($_)
        }
    }

    Update-GUI
    Write-Log 'DBG' "Search CSV ended with $($wpf.CSVGrid.Items.Count) matches"
}