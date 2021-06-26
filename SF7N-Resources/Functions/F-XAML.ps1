function Get-XAML {
    $Hash = [Hashtable]::Synchronized(@{})
    
    Write-Log 'INF' '    - Injection'
    [Xml] $Xaml = Get-Content .\GUI.xaml
    $Xaml = Set-XAMLTheme $Xaml

    Write-Log 'INF' '    - Parse'
    $Form = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::New($Xaml))

    Write-Log 'INF' '    - Node Identification'
    $Xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.ForEach({
        if ($Hash.Keys -notcontains $_) {$Hash.Add($_, $Form.FindName($_))}
    })
    return $Hash
}

function Set-XAMLTheme ($Xaml) {
    $Theme = ".\Configurations\Themes\$($context.Theme).ini"
    if (!(Test-Path $Theme)) {return $Xaml}
        
    $Resource = $Xaml.Window.'Window.Resources'
    # Because ConvertFrom-StringData doesn't like space paddings,
    # we have to parse the theme .ini manually
    foreach ($Line in (Get-Content $Theme)) {
        $Data = $Line.Split('=').Trim()
        $ThisBrush = "Brush_" + $Data[0]
        $ThisValue = $Data[1]
        
        # Apply SolidColorBrush
        $Resource.SolidColorBrush.Where({$_.Key -eq $ThisBrush}).ForEach({
            $_.Color = $ThisValue
        })
    }

    # Apply Color (Foreground/Highlight/Control){
    foreach ($Color in $Resource.Color) {
        $BrushName = $Color.Key -replace 'Color','Brush'

        $Resource.SolidColorBrush.Where({$_.Key -eq $BrushName}).
        Color.Substring(1).ForEach({
            $Color.R = [String][Convert]::ToInt16($_.Substring(0,2), 16)
            $Color.G = [String][Convert]::ToInt16($_.Substring(2,2), 16)
            $Color.B = [String][Convert]::ToInt16($_.Substring(4,2), 16)
        })
    }
    return $Xaml
}
