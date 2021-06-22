function Search-CSV ($SearchText, $FirstRun) {
    # Initialize
    $wpf.CSVGrid.ItemsSource = $null
    Set-DataContext Preview $null
    if (!$FirstRun) {Set-DataContext Status 'Processing'}

    # Parse SearchRules Text into [PSCustomObject] $SearchTerm
    $SearchTerm = [PSCustomObject] @{}
    $Regex = '(["'']?)(?(1)(.+?|[\S"'']+?))\1[:=](["'']?)(?(1)(.+?|[\S"'']+?))\3(?:\s|$)'

    ($SearchText | Select-String $Regex -AllMatches).Matches.ForEach({
        $SearchTerm |
        Add-Member -MemberType NoteProperty -Name $_.Groups[2].Value -Value $_.Groups[4].Value
    })

    # Apply input alias
    if ($context.InputAlias) {
        $SearchTerm.PSObject.Properties.ForEach({
            $Header = $_.Name
            for ($i = 0; $i -lt $csvAlias.$Header.Count; $i += 2) {
                $_.Value = $_.Value.Replace($csvAlias[$i+1].$Header, $csvAlias[$i].$Header)
            }
        })
    }

    # Search with new Powershell instance
    $Ps = [PowerShell]::Create().AddScript{
        function Update-GUI ([Action] $Action) {
            $wpf.SF7N.Dispatcher.Invoke([Action] $Action, 'Normal')
        }

        [Collections.ArrayList] $CsvSearch = @()
        foreach ($Entry in $csv) {
            # If notMatch, goto next iteration
            if (!$FirstRun -or ('' -eq $SearchTerm)) {
                $SearchTerm.PSObject.Properties.ForEach({
                    if ($Entry.($_.Name) -notmatch $_.Value) {continue}
                })
            }
        
            # Apply alias if OutputAlias is on; else add raw content
            if ($context.OutputAlias) {
                $Row = $Entry.PSObject.Copy()
                $Row.PSObject.Properties.ForEach({
                    $Header = $_.Name
                    for ($i = 0; $i -lt $csvAlias.$Header.Count; $i += 2) {
                        $_.Value = $_.Value.Replace($csvAlias[$i].$Header, $csvAlias[$i+1].$Header)
                    }
                })
                $CsvSearch.Add($Row)
                
            } else {
                $CsvSearch.Add($Entry)
            }

            if ($CsvSearch.Count -eq 25) {
                Update-GUI {$wpf.CSVGrid.ItemsSource = $CsvSearch.PSObject.Copy()}
            }
        }
        Update-GUI {$wpf.CSVGrid.ItemsSource = $wpf.CSVGrid.ItemsSource = $CsvSearch}
        $context.Status = 'Ready'
        Update-GUI {$wpf.SF7N.DataContext = $null}
        Update-GUI {$wpf.SF7N.DataContext = $context}
    }
    
    # Assign runspace to instance
    $Ps.Runspace = [RunspaceFactory]::CreateRunspace()
    $Ps.Runspace.ApartmentState = 'STA'
    $Ps.Runspace.ThreadOptions = 'ReuseThread'
    $Ps.Runspace.Open()
    (Get-Variable wpf,csv,SearchTerm,csvAlias,context,FirstRun).ForEach({
        $Ps.Runspace.SessionStateProxy.SetVariable($_.Name, $_.Value)
    })
    $Ps.BeginInvoke()
}
