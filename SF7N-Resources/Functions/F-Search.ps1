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

function Search-CSV ($SearchText, $FirstRun) {
    # Initialize
    $wpf.CSVGrid.ItemsSource = $null
    Set-DataContext Preview $null
    if (!$FirstRun) {Set-DataContext Status 'Processing'}

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
    # Pass variables
    ('wpf','csv','SearchTerm','csvAlias','context','FirstRun').ForEach({
        $RunSpace.SessionStateProxy.SetVariable($_, (Get-Variable $_).Value)
    })
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
            if (!$FirstRun) {
                $SearchTerm.PSObject.Properties.ForEach{
                    if ($Entry.($_.Name) -notmatch $_.Value) {continue}
                }
            }
        
            # Apply alias if AliasMode is on; else add raw content
            if ($context.AliasMode) {
                $CsvSearch.Add((ConvertTo-Alias $Entry.PsObject.Copy()))
            } else {
                $CsvSearch.Add($Entry)
            }

            if ($CsvSearch.Count -eq 25) {
                $wpf.SF7N.Dispatcher.Invoke([Action] {$wpf.CSVGrid.ItemsSource = $CsvSearch.PSObject.Copy()}, 'Normal')
            }
        }
        $wpf.SF7N.Dispatcher.Invoke([Action] {$wpf.CSVGrid.ItemsSource = $CsvSearch}, 'Normal')
        $context.Status = 'Ready'
        $wpf.SF7N.Dispatcher.Invoke([Action] {$wpf.SF7N.DataContext = $null}, 'Normal')
        $wpf.SF7N.Dispatcher.Invoke([Action] {$wpf.SF7N.DataContext = $context}, 'Normal')
    }
    $Ps.Runspace = $Runspace
    $Ps.BeginInvoke()
}