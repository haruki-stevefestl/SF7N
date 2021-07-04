function New-GUI ($ImportFrom) {
    Write-Log 'New    GUI'
    Write-Log '  - Read XAML'
    [Xml] $Xaml = Get-Content $ImportFrom
    $Xaml = Set-GUITheme $Xaml

    Write-Log '  - Parse XAML'
    $Form = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::New($Xaml))

    # Populate $Hash with elements
    Write-Log '  - Identify Nodes'
    $Hash = [Hashtable]::Synchronized(@{})
    $Xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.ForEach({
        if ($Hash.Keys -notcontains $_) {$Hash.Add($_, $Form.FindName($_))}
    })
    return $Hash
}

function Set-GUITheme ($Xaml) {
    Write-Log '  - Set-GUITheme'
    $Theme = ".\Configurations\Themes\$($context.Theme).ini"
    if (Test-Path $Theme) {
        $Resource = $Xaml.Window.'Window.Resources'
        
        # ConvertFrom-StringData hates paddings so parse the .ini manually
        foreach ($Line in (Get-Content $Theme)) {
            $Data = $Line.Split('=').Trim()
            $ThisBrush = "Brush_" + $Data[0]
            $ThisValue = $Data[1]

            # Apply SolidColorBrush
            $Resource.SolidColorBrush.Where({$_.Key -eq $ThisBrush}).ForEach({
                $_.Color = $ThisValue
            })
        }

        # Convert SolidColorBrush to Color
        # Required for datagrids (only accepts Color)
        foreach ($Color in $Resource.Color) {
            $BrushName = $Color.Key -replace 'Color','Brush'

            $Resource.SolidColorBrush.Where({$_.Key -eq $BrushName}).
            Color.Substring(1).ForEach({
                $Color.R = [String][Convert]::ToInt16($_.Substring(0,2), 16)
                $Color.G = [String][Convert]::ToInt16($_.Substring(2,2), 16)
                $Color.B = [String][Convert]::ToInt16($_.Substring(4,2), 16)
            })
        }
    }
    return $Xaml
}
