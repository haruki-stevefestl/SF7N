function Search-CSV ($SearchText) {
    # Initialize
    if ($csv.Count -eq 0) {
        Set-DataContext $context Status Editing
        return
    }

    $wpf.CSVGrid.ItemsSource = $null
    $wpf.Commit.IsEnabled = $false
    Set-DataContext $context Preview $null
    Set-DataContext $context Status Searching

    # Parse SearchRules Text into [PSCustomObject] $SearchTerm
    $SearchTerm = [PSCustomObject] @{}
    $Regex = '(["'']?)(.+?)\1[:=](["'']?)(.+?)\3(\s|$)'

    ($SearchText | Select-String $Regex -AllMatches).Matches.ForEach({
        $SearchTerm |
        Add-Member -NotePropertyName $_.Groups[2].Value $_.Groups[4].Value
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
            $wpf.SF7N.Dispatcher.Invoke($Action, 'ApplicationIdle')
        }

        [Collections.ArrayList] $CsvSearch = @()
        foreach ($Entry in $csv) {
            if ('' -ne $SearchTerm) {
                # If notMatch, goto next iteration
                $SearchTerm.PSObject.Properties.ForEach({
                    if ($Entry.($_.Name) -notmatch $_.Value) {continue}
                })
            }
        
            # Add entry; apply alias if OutputAlias is on 
            if ($context.EditOutput -eq 0) {
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

            # Show preliminary results
            if ($CsvSearch.Count -eq 25) {
                Update-GUI {$wpf.CSVGrid.ItemsSource = $CsvSearch.PSObject.Copy()}
            }
        }
        # Show full results
        Update-GUI {$wpf.CSVGrid.ItemsSource = $CsvSearch}
        $context.Status = 'Ready'
        Update-GUI {$wpf.SF7N.DataContext = $null}
        Update-GUI {$wpf.SF7N.DataContext = $context}
    }
    
    # Assign runspace to instance
    $Ps.Runspace = [RunspaceFactory]::CreateRunspace()
    $Ps.Runspace.ApartmentState = 'STA'
    $Ps.Runspace.ThreadOptions = 'ReuseThread'
    $Ps.Runspace.Open()
    (Get-Variable wpf,csv,SearchTerm,csvAlias,context).ForEach({
        $Ps.Runspace.SessionStateProxy.SetVariable($_.Name, $_.Value)
    })
    $Ps.BeginInvoke()
}
