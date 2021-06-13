function Get-XAML {
    $Result = [Hashtable]::Synchronized(@{})

    Write-Log 'INF' 'Read   XAML'
    [Array] $Xaml = Get-Content .\GUI.xaml
    
    Write-Log 'DBG' 'Inject XAML theming'    
    $Xaml = Set-XAMLTheme $Xaml

    Write-Log 'INF' 'Parse  XAML'
    [Xml] $Xaml = $Xaml
    $TempForm = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::New($Xaml))
    $ErrorActionPreference = 'SilentlyContinue'
    $Xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
        ForEach{$Result.Add($_, $TempForm.FindName($_))}
    $ErrorActionPreference = 'Continue'
    return $Result
}

function Set-XAMLTheme ($Xaml) {
    # Define colors
    $Color = [Hashtable] @{ # Fallback, light theme
            Background = 'FFFFFF'
            Caption    = '696969'
            Header     = 'EEEEEE'
            Foreground = '000000'
            Highlight  = 'CCE8FF'
            Control    = 'E5F3FF'
    }

    $Theme = ".\Configurations\Themes\$($dataContext.Theme).ini"
    if (Test-Path $Theme) {
        # Because ConvertFrom-StringData doesn't provide a [Hashtable],
        # we're manually parsing each line of the theme file
        (Get-Content $Theme).ForEach({
            $ThisLine = $_.Split('=')
            $Color.($ThisLine[0].Trim()) = $ThisLine[1].Trim()
        })
    }

    # Some places require Color, not SolidColorBrush
    $Color.Add('Foreground_', @(
        [Convert]::ToInt16($Color.Foreground.Substring(0,2), 16),
        [Convert]::ToInt16($Color.Foreground.Substring(2,2), 16),
        [Convert]::ToInt16($Color.Foreground.Substring(4,2), 16)
    ))
    $Color.Add('Highlight_', @(
        [Convert]::ToInt16($Color.Highlight.Substring(0,2), 16),
        [Convert]::ToInt16($Color.Highlight.Substring(2,2), 16),
        [Convert]::ToInt16($Color.Highlight.Substring(4,2), 16)
    ))
    $Color.Add('Control_', @(
        [Convert]::ToInt16($Color.Control.Substring(0,2), 16),
        [Convert]::ToInt16($Color.Control.Substring(2,2), 16),
        [Convert]::ToInt16($Color.Control.Substring(4,2), 16)
    ))
    
    # Inject into XAML
    $Xaml[6]  = '<SolidColorBrush x:Key="Color_Background" Color="#'+ $Color.Background +'"/>'
    $Xaml[7]  = '<SolidColorBrush x:Key="Color_Caption"    Color="#'+ $Color.Caption    +'"/>'
    $Xaml[8]  = '<SolidColorBrush x:Key="Color_Header"     Color="#'+ $Color.Header     +'"/>'
    $Xaml[9]  = '<SolidColorBrush x:Key="Color_Foreground" Color="#'+ $Color.Foreground +'"/>'
    $Xaml[10] = '<SolidColorBrush x:Key="Color_Highlight"  Color="#'+ $Color.Highlight  +'"/>'
    $Xaml[11] = '<SolidColorBrush x:Key="Color_Control"    Color="#'+ $Color.Control    +'"/>'
    $Xaml[12] = '<Color x:Key="Color__Highlight"  R="'+ $Color.Highlight_[0]  +'" G="'+ $Color.Highlight_[1]  +'" B="'+ $Color.Highlight_[2]  +'" A="255"/>'
    $Xaml[13] = '<Color x:Key="Color__Control"    R="'+ $Color.Control_[0]    +'" G="'+ $Color.Control_[1]    +'" B="'+ $Color.Control_[2]    +'" A="255"/>'
    $Xaml[14] = '<Color x:Key="Color__Foreground" R="'+ $Color.Foreground_[0] +'" G="'+ $Color.Foreground_[1] +'" B="'+ $Color.Foreground_[2] +'" A="255"/>'
    return $Xaml
}