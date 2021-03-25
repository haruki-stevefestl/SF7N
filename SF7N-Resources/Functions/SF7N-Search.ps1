#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function ConvertFrom-AliasMode ($Row) {
    if ($null -ne $csvAlias) {
        $Row.PSObject.Properties.Foreach({
            $_.Value = $_.Value -ireplace
                ($csvAlias[1].($_.Name), $csvAlias[0].($_.Name)) -ireplace
                ($csvAlias[3].($_.Name), $csvAlias[2].($_.Name)) -ireplace
                ($csvAlias[5].($_.Name), $csvAlias[4].($_.Name))
        })
    }
    return $Row
}

function ConvertTo-AliasMode ($Row) {
    if ($null -ne $csvAlias) {
        $Row.PSObject.Properties.Foreach({
            $_.Value = $_.Value -ireplace
                ($csvAlias[0].($_.Name), $csvAlias[1].($_.Name)) -ireplace
                ($csvAlias[2].($_.Name), $csvAlias[3].($_.Name)) -ireplace
                ($csvAlias[4].($_.Name), $csvAlias[5].($_.Name))
        })
    }
    return $Row
}

function Search-CSV ($SearchText) {
    # Initialize
    [Collections.ArrayList] $script:csvSearch = @()
    $wpf.CSVGrid.ItemsSource = $csvSearch

    # Parse SearchRules Text into [PSCustomObject] $SearchTerm
    $SearchTerm = [PSCustomObject] @{}

    # While there are search terms in $SearchText
    #     Add to $SearchTerm
    #     Remove from $SearchText
    while (
        $SearchText -match
        '(["'']?)(?(1)(.+?|[\S"'']+?))\1:(["'']?)(?(1)(.+?|[\S"'']+?))\3(?:\s|$)'
    ) {
        $SearchTerm | Add-Member -MemberType NoteProperty -Name $Matches[2] -Value $Matches[4]
        $SearchText = $SearchText.Replace($Matches[0], '')
    }

    # Apply input assist
    if ($wpf.InputAssist.IsChecked) {
        $SearchTerm = ConvertFrom-AliasMode $SearchTerm
    }

    # Search
    foreach ($Entry in $csv) {
        # If notMatch, goto next iteration
        $SearchTerm.PSObject.Properties.ForEach({
            if ($Entry.($_.Name) -notmatch $_.Value) {continue}
        })

        # Apply alias if AliasMode is on; else add raw content
        if ($wpf.AliasMode.IsChecked) {
            $csvSearch.Add((ConvertTo-AliasMode $Entry.PsObject.Copy()))
        } else {
            $csvSearch.Add($Entry)
        }
    }

    $wpf.TotalRows.Text = "Total rows: $($wpf.CSVGrid.Items.Count)"
    Write-Log 'INF' "Search CSV ended; $($wpf.CSVGrid.Items.Count) matches"
    Update-GUI
}
