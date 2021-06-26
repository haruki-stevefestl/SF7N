function Get-XAML {
    $Result = [Hashtable]::Synchronized(@{})
    
    Write-Log 'INF' '    - Injection'
    [Xml] $Xaml = Get-Content .\GUI.xaml
    $Xaml = Set-XAMLTheme $Xaml

    Write-Log 'INF' '    - Parse'
    $TempForm = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::New($Xaml))

    Write-Log 'INF' '    - Node Identification'
    $ErrorActionPreference = 'SilentlyContinue'
    $Xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
        ForEach{$Result.Add($_, $TempForm.FindName($_))}
    $ErrorActionPreference = 'Continue'
    return $Result
}

function Set-XAMLTheme ($Xaml) {
    $Theme = ".\Configurations\Themes\$($context.Theme).ini"
    if (Test-Path $Theme) {
        # Because ConvertFrom-StringData doesn't like space paddings,
        # we have to parse the theme .ini manually
        (Get-Content $Theme).ForEach({
            $ThisBrush = "Brush_" + $_.Split('=')[0].Trim()
            $ThisValue = $_.Split('=')[1].Trim()
            
            # Apply color
            $Xaml.Window.'Window.Resources'.SolidColorBrush.Where({$_.Key -eq $ThisBrush}).ForEach({
                $_.Color = $ThisValue
            })
        })
    }
    return $Xaml
}
