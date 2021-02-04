#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Update-GUI {
    $wpf.SF7N.Dispatcher.Invoke("Render",[action][scriptblock]{})
}

function Set-Preview {
    # Set preview image of illustration
    $InputObject = $previewLocation + '\' +
        $wpf.CSVGrid.CurrentCell.Item.$previewColumn +
        $previewExtension

    if ((Test-Path $InputObject) -and ($null -ne $InputObject)) {$wpf.Preview.Source = $InputObject}

    # Update Active Cell
    $wpf.ActiveCell.Text =
        'Active Cell: (' +
        $wpf.CSVGrid.Items.Indexof($wpf.CSVGrid.SelectedCells[0].Item) +
        ',' +
        $wpf.CSVGrid.SelectedCells[0].Column.DisplayIndex +
        ') ~ (' +
        $wpf.CSVGrid.Items.Indexof($wpf.CSVGrid.SelectedCells[-1].Item) +
        ',' +
        $wpf.CSVGrid.SelectedCells[-1].Column.DisplayIndex +
        ')'
}
