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

    if (Test-Path $PreviewPath) {
        $wpf.PreviewImage.Source = $PreviewPath
    } else {
        $wpf.PreviewImage.Source = $null
    }

    # Display # of rows selected
    $wpf.SelectedRows.Text = "$($wpf.CSVGrid.SelectedItems.Count) selected"
}
