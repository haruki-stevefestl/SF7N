#-----------------------------------------------------------------------------+---------------------
# Global actions
$wpf.PreviewCopy.Add_Click({
    if ($null -ne $wpf.PreviewImage.Source) {
        [Windows.Forms.Clipboard]::SetImage([Drawing.Image]::FromFile(
            $wpf.PreviewImage.Source -replace 'file:///',''
        ))
    }
})
