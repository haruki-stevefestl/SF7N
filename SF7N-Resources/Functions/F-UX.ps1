#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Update-GUI {
    $wpf.SF7N.Dispatcher.Invoke('Render', [Action][Scriptblock]{})
}

function Set-Preview {
    # Set preview image of illustration
    $PreviewPath =
        $previewLocation + '\' +
        $wpf.CSVGrid.CurrentCell.Item.($config.previewColumn) +
        $config.previewExtension

    if (Test-Path $PreviewPath) {$wpf.PreviewImage.Source = $PreviewPath}

    # Update Active Cell
    $wpf.ActiveCell.Text = 'Active Cell: ({0},{1}) ~ ({2},{3})' -f (
        $wpf.CSVGrid.Items.IndexOf($wpf.CSVGrid.SelectedCells[0].Item),
        $wpf.CSVGrid.SelectedCells[0].Column.DisplayIndex,
        $wpf.CSVGrid.Items.IndexOf($wpf.CSVGrid.SelectedCells[-1].Item),
        $wpf.CSVGrid.SelectedCells[-1].Column.DisplayIndex
    )
}
