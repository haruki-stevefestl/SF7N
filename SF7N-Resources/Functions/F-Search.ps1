#-----------------------------------------------------------------------------+---------------------
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

function Search-CSV ($SearchText) {
    # Initialize
    $wpf.CSVGrid.ItemsSource = $null
    $wpf.PreviewImage.Source = $null

    # Parse SearchRules Text into [PSCustomObject]$SearchTerm
    $SearchTerm = [PSCustomObject] @{}

    # While there are search terms in $SearchText
    #     Add to $SearchTerm
    #     Remove from $SearchText
    while (
        $SearchText -match
        '(["'']?)(?(1)(.+?|[\S"'']+?))\1[:=](["'']?)(?(1)(.+?|[\S"'']+?))\3(?:\s|$)'
    ) {
        $SearchTerm | Add-Member -MemberType NoteProperty -Name $Matches[2] -Value $Matches[4]
        $SearchText = $SearchText.Replace($Matches[0], '')
    }

    # Apply input assist
    if ($wpf.InputAssist.IsChecked) {$SearchTerm = ConvertFrom-AliasMode $SearchTerm}

    # Search
    $Runspace = [RunspaceFactory]::CreateRunspace()
    $Runspace.ApartmentState = 'STA'
    $Runspace.ThreadOptions = 'ReuseThread'        
    $Runspace.Open()
    $Runspace.SessionStateProxy.SetVariable('wpf',$wpf)
    $Runspace.SessionStateProxy.SetVariable('csv',$csv)
    $Runspace.SessionStateProxy.SetVariable('searchTerm',$searchTerm)
    $Runspace.SessionStateProxy.SetVariable('csvAlias',$csvAlias)
    $Runspace.SessionStateProxy.SetVariable('aliasMode',$wpf.AliasMode.IsChecked)
    $Ps = [PowerShell]::Create().AddScript({
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

        [Collections.ArrayList] $CsvSearch = @()
        foreach ($Entry in $csv) {
            # If notMatch, goto next iteration
            $SearchTerm.PSObject.Properties.ForEach({
                if ($Entry.($_.Name) -notmatch $_.Value) {continue}
            })
    
            # Apply alias if AliasMode is on; else add raw content
            if ($aliasMode) {
                $csvSearch.Add((ConvertTo-AliasMode $Entry.PsObject.Copy()))
            } else {
                $CsvSearch.Add($Entry)
            }
        }

        $wpf.SF7N.Dispatcher.Invoke([Action] {$wpf.CSVGrid.ItemsSource = $CsvSearch}, 'Normal')
    })
    $Ps.Runspace = $Runspace
    $Ps.BeginInvoke()
}