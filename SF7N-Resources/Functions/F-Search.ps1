function ConvertFrom-Alias ($Row) {
    if ($csvAlias) {
        $Row.PSObject.Properties.Foreach{
            $Header = $_.Name
            for ($i = 0; $i -lt $csvAlias.$Header.Count; $i += 2) {
                $_.Value = $_.Value.Replace($csvAlias[$i+1].$Header, $csvAlias[$i].$Header)
            }
        }
    }
    return $Row
}

function Search-CSV ($SearchText) {
    # Initialize
    $wpf.CSVGrid.ItemsSource = $wpf.PreviewImage.Source = $null

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
    if ($wpf.InputAssist.IsChecked) {$SearchTerm = ConvertFrom-Alias $SearchTerm}

    # Search with new runspace
    $Runspace = [RunspaceFactory]::CreateRunspace()
    $Runspace.ApartmentState = 'STA'
    $Runspace.ThreadOptions = 'ReuseThread'
    $Runspace.Open()
    $Runspace.SessionStateProxy.SetVariable('wpf',$wpf)
    $Runspace.SessionStateProxy.SetVariable('csv',$csv)
    $Runspace.SessionStateProxy.SetVariable('searchTerm',$searchTerm)
    $Runspace.SessionStateProxy.SetVariable('csvAlias',$csvAlias)
    $Runspace.SessionStateProxy.SetVariable('aliasMode',$wpf.Config_AliasMode.IsChecked)
    $Ps = [PowerShell]::Create().AddScript{
        function ConvertTo-Alias ($Row) {
            if ($csvAlias) {
                $Row.PSObject.Properties.Foreach{
                    $Header = $_.Name
                    for ($i = 0; $i -lt $csvAlias.$Header.Count; $i += 2) {
                        $_.Value = $_.Value.Replace($csvAlias[$i].$Header, $csvAlias[$i+1].$Header)
                    }
                }
            }
            return $Row
        }

        [Collections.ArrayList] $CsvSearch = @()
        foreach ($Entry in $csv) {
            # If notMatch, goto next iteration
            $SearchTerm.PSObject.Properties.ForEach{
                if ($Entry.($_.Name) -notmatch $_.Value) {continue}
            }
    
            # Apply alias if AliasMode is on; else add raw content
            if ($aliasMode) {
                $CsvSearch.Add((ConvertTo-Alias $Entry.PsObject.Copy()))
            } else {
                $CsvSearch.Add($Entry)
            }
        }

        $wpf.SF7N.Dispatcher.Invoke([Action] {$wpf.CSVGrid.ItemsSource = $CsvSearch}, 'ApplicationIdle')
    }
    $Ps.Runspace = $Runspace
    $Ps.BeginInvoke()
}