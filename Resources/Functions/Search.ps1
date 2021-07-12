function Search-CSV ($SearchText, $SearchFrom) {
    # Initialize
    if ($SearchFrom.Count -eq 0) {
        $wpf.Status.Text = 'Editing'
        return
    }

    $wpf.CSVGrid.ItemsSource = $null
    $wpf.Commit.IsEnabled = $false
    $wpf.Status.Text = 'Searching'
    $wpf.Preview.Source = $null

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
            # Take into account of empty alias strings
            $Count  = ($SearchFromAlias.$Header | Where-Object {$_}).Count
            for ($i = 0; $i -lt $Count; $i += 2) {
                $_.Value = $_.Value.Replace($SearchFromAlias[$i+1].$Header, $SearchFromAlias[$i].$Header)
            }
        })
    }

    # Search with new Powershell instance
    $Ps = [PowerShell]::Create().AddScript{
        function Update-GUI ([Action] $Action) {
            $wpf.SF7N.Dispatcher.Invoke($Action, 'ApplicationIdle')
        }

        [Collections.ArrayList] $SearchFromSearch = @()
        foreach ($Entry in $SearchFrom) {
            if ('' -ne $SearchTerm) {
                # If notMatch, goto next iteration
                $SearchTerm.PSObject.Properties.ForEach({
                    if ($Entry.($_.Name) -notmatch $_.Value) {continue}
                })
            }
        
            # Add entry; apply alias if OutputAlias is on 
            if ($context.OutputAlias) {
                $Row = $Entry.PSObject.Copy()
                $Row.PSObject.Properties.ForEach({
                    $Header = $_.Name
                    # Take into account of empty alias strings
                    $Count  = ($SearchFromAlias.$Header | Where-Object {$_}).Count
                    for ($i = 0; $i -lt $Count; $i += 2) {
                        $_.Value = $_.Value.Replace($SearchFromAlias[$i].$Header, $SearchFromAlias[$i+1].$Header)
                    }
                })
                $SearchFromSearch.Add($Row)
            } else {
                $SearchFromSearch.Add($Entry)
            }

            # Show preliminary results
            if ($SearchFromSearch.Count -eq 25) {
                Update-GUI {$wpf.CSVGrid.ItemsSource = $SearchFromSearch.PSObject.Copy()}
            }
        }
        # Show full results
        Update-GUI {$wpf.CSVGrid.ItemsSource = $SearchFromSearch}
        Update-GUI {$wpf.Status.Text = 'Ready'}
    }
    
    # Assign runspace to instance
    $Ps.Runspace = [RunspaceFactory]::CreateRunspace()
    $Ps.Runspace.ApartmentState = 'STA'
    $Ps.Runspace.ThreadOptions = 'ReuseThread'
    $Ps.Runspace.Open()
    (Get-Variable wpf,SearchFrom,SearchTerm,csvAlias,context).ForEach({
        $Ps.Runspace.SessionStateProxy.SetVariable($_.Name, $_.Value)
    })
    $Ps.BeginInvoke()
    $wpf.TabControl.SelectedIndex = 1
}
