# Work after splashscreen shows
$wpf.SF7N.Add_ContentRendered({
    Import-Module .\Functions\Initialize.ps1 -Force
    Initialize-SF7N

    Write-Log 'Import WinForms'
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing 

    Search-CSV $wpf.Searchbar.Text
    Start-Sleep 1
    $wpf.TabControl.SelectedIndex = 1
})

# Prompt exit if unsaved
$wpf.SF7N.Add_Closing({
    if ($wpf.Commit.IsEnabled) {
        $Dialog = New-Dialog 'Commit changes before exiting?' 'YesNoCancel' 'Question'
        if ($Dialog -eq 'Cancel') {
            $_.Cancel = $true
        } elseif ($Dialog -eq 'Yes') {
            Export-CustomCSV $context.csvLocation
        }
    }

    # Cleanup
    Remove-Variable baseDir,config,context,csv,
        csvAlias,csvHeader,startTime,wpf -Scope Script -Force
})
