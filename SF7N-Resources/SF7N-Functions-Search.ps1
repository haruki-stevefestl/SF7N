#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Search-CSV {
    # Initialize
    Write-Log 'INF' 'Search CSV'
    $wpf.CSVGrid.ItemsSource = $null
    $wpf.CSVGrid.Items.Clear()
    $script:csvSearch = @()

    # Parse SearchRules Text into $SearchTerms
    $SearchText = $wpf.SearchRules.Text
    $SplitRule  = '(?<=\s|^)(?:([^\s"]+?)|"(.+?)"):(?:([^\s"]+?)|"(.+?)")(?:\s|$)'
    [Hashtable] $script:SearchTerm = @{}

    # Thanks my Computer Subject Teacher for teaching me
    # how to parse text with a WHILE loop (but in Pascal).
    # Also Powershell why do you not support the GLOBAL regex flag?

    # Main parsing loop
    while ($SearchText -match $SplitRule) {
        $Key   = if ($null -eq $Matches[1]) {$Matches[2]} else {$Matches[1]}
        $Value = if ($null -eq $Matches[3]) {$Matches[4]} else {$Matches[3]}

        $script:searchTerm.Add($Key, $Value)
        $SearchText = $SearchText.Replace($Matches[0], '')
    }

    # Apply input assist
    if ($wpf.InputAssist.IsChecked) {
        $SearchTerm.Keys.Clone() | ForEach-Object {
            $SearchTerm[$_] = $SearchTerm[$_] -ireplace
                ($csvAlias[1].($SearchTerm.Keys), $csvAlias[0].($SearchTerm.Keys)) -ireplace
                ($csvAlias[3].($SearchTerm.Keys), $csvAlias[2].($SearchTerm.Keys)) -ireplace
                ($csvAlias[5].($SearchTerm.Keys), $csvAlias[4].($SearchTerm.Keys))
        }
    }
    
    # Search
    :nextEntry foreach ($Entry in $csv) {
        foreach ($Term in $searchTerm) {
            if (
                $Entry.$($Term.Keys) -notmatch
                $Term.Values
            ) {continue nextEntry}
        }

        # Apply alias if AliasMode is on; else add raw content
        if ($wpf.AliasMode.IsChecked) {
            $TempRow = $Entry.PsObject.Copy()
            $TempRow.PSObject.Properties.Foreach({
                $_.Value = $_.Value -replace
                    $csvAlias[0].($_.Name),$csvAlias[1].($_.Name) -replace
                    $csvAlias[2].($_.Name),$csvAlias[3].($_.Name) -replace
                    $csvAlias[4].($_.Name),$csvAlias[5].($_.Name)
            })
            $script:csvSearch.Add($TempRow)
        } else {
            $script:csvSearch.Add($Entry)
        }
    }

    $wpf.CSVGrid.ItemsSource = $script:csvSearch
    $wpf.TotalRows.Text = "Total rows: $($wpf.CSVGrid.Items.Count)"
    Update-GUI
    Write-Log 'DBG' "Search CSV ended; $($wpf.CSVGrid.Items.Count) matches"
}