function Export-CustomCSV ($ExportTo) {
    $wpf.CSVGrid.Items | Export-CSV $ExportTo -NoTypeInformation
}