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
        Background = '#FFFFFF'
        Caption    = '#696969'
        Header     = '#EEEEEE'
        Foreground = '#000000'
        Highlight  = '#CCE8FF'
        Control    = '#E5F3FF'
        Border     = '#727272'
        Scroll_Static    = '#EEEEEE'
        Scroll_MouseOver = '#DDDDDD'
        Scroll_Pressed   = '#CCCCCC'
        Button_Background   = '#DDDDDD'
        Button_MouseOver    = '#BEE6FD'
        Button_Pressed      = '#C4E5F6'
    }

    $Theme = ".\Configurations\Themes\$($context.Theme).ini"
    if (Test-Path $Theme) {
        # Because ConvertFrom-StringData doesn't provide a [Hashtable],
        # we're manually parsing each line of the theme file
        (Get-Content $Theme).ForEach({
            $ThisLine = $_.Split('=')
            $Color.($ThisLine[0].Trim()) = $ThisLine[1].Trim()
        })
    }

    # BrushKeys require Color, not SolidColorBrush
    $Color.Add('Foreground_', @(
        [Convert]::ToInt16($Color.Foreground.Substring(1,2), 16),
        [Convert]::ToInt16($Color.Foreground.Substring(3,2), 16),
        [Convert]::ToInt16($Color.Foreground.Substring(5,2), 16)
    ))
    $Color.Add('Highlight_', @(
        [Convert]::ToInt16($Color.Highlight.Substring(1,2), 16),
        [Convert]::ToInt16($Color.Highlight.Substring(3,2), 16),
        [Convert]::ToInt16($Color.Highlight.Substring(5,2), 16)
    ))
    $Color.Add('Control_', @(
        [Convert]::ToInt16($Color.Control.Substring(1,2), 16),
        [Convert]::ToInt16($Color.Control.Substring(3,2), 16),
        [Convert]::ToInt16($Color.Control.Substring(5,2), 16)
    ))
    
    # Inject into XAML
    # Since the brushes will be sealed, it is impossible to change them at run-time
    $Xaml[6]  = '<SolidColorBrush x:Key="Brush_Background" Color="'+ $Color.Background +'"/>'
    $Xaml[7]  = '<SolidColorBrush x:Key="Brush_Caption"    Color="'+ $Color.Caption    +'"/>'
    $Xaml[8]  = '<SolidColorBrush x:Key="Brush_Header"     Color="'+ $Color.Header     +'"/>'
    $Xaml[9]  = '<SolidColorBrush x:Key="Brush_Foreground" Color="'+ $Color.Foreground +'"/>'
    $Xaml[10] = '<SolidColorBrush x:Key="Brush_Highlight"  Color="'+ $Color.Highlight  +'"/>'
    $Xaml[11] = '<SolidColorBrush x:Key="Brush_Control"    Color="'+ $Color.Control    +'"/>'
    $Xaml[12] = '<SolidColorBrush x:Key="Brush_Border"     Color="'+ $Color.Border     +'"/>'
    $Xaml[13] = '<Color x:Key="Color_Highlight"  R="'+ $Color.Highlight_[0]  +'" G="'+ $Color.Highlight_[1]  +'" B="'+ $Color.Highlight_[2]  +'" A="255"/>'
    $Xaml[14] = '<Color x:Key="Color_Control"    R="'+ $Color.Control_[0]    +'" G="'+ $Color.Control_[1]    +'" B="'+ $Color.Control_[2]    +'" A="255"/>'
    $Xaml[15] = '<Color x:Key="Color_Foreground" R="'+ $Color.Foreground_[0] +'" G="'+ $Color.Foreground_[1] +'" B="'+ $Color.Foreground_[2] +'" A="255"/>'
    $Xaml[16] = '<SolidColorBrush x:Key="Brush_Scroll_Static"     Color="'+ $Color.Scroll_Static +'"/>'
    $Xaml[17] = '<SolidColorBrush x:Key="Brush_Scroll_MouseOver"  Color="'+ $Color.Scroll_MouseOver +'"/>'
    $Xaml[18] = '<SolidColorBrush x:Key="Brush_Scroll_Pressed"    Color="'+ $Color.Scroll_Pressed +'"/>'
    $Xaml[19] = '<SolidColorBrush x:Key="Brush_Button_Background" Color="'+ $Color.Button_Background +'"/>'
    $Xaml[20] = '<SolidColorBrush x:Key="Brush_Button_MouseOver"  Color="'+ $Color.Button_MouseOver +'"/>'
    $Xaml[21] = '<SolidColorBrush x:Key="Brush_Button_Pressed"    Color="'+ $Color.Button_Pressed +'"/>'
    return $Xaml
}