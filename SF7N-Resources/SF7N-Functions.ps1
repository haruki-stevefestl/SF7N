function Update-GUI {
    $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})
}

function Write-Log ($Location, $Type, $Message) {
    Write-Host "[$(Get-Date -Format HH:mm:ss.fff)][$Location][$Type][$Message]"
}

function Update-CSV ($ImportFrom) {
    [System.Collections.ArrayList] $global:csvRaw    = [System.IO.File]::ReadAllText($csvLocation) | ConvertFrom-Csv
    [System.Collections.ArrayList] $global:csv       = $csvRaw[8..$csvRaw.Count]
    [System.Collections.ArrayList] $global:csvAlias  = $csvRaw[1..7]
    $global:csvHeader = (Get-Content $csvLocation -First 1) -replace '"','' -split ','
    [System.Collections.ArrayList] $global:csvSearch = @()
}

function Search-CSV {
    # Initialize
    $global:csvSearch = @()
    $wpf.CSVGrid.ItemsSource = $null
    
    # Search
    $csv.ForEach({
        if (
            # Conditions
            $_.ID        -match $wpf.TextBox_ID.Text        -and
            $_.Viewpoint -match $wpf.TextBox_Viewpoint.Text -and
            $_.Location  -match $wpf.TextBox_Location.Text  -and
            $_.Collar    -match $wpf.TextBox_Collar.Text    -and
            $_.Tie       -match $wpf.TextBox_Tie.Text       -and
            $_.Skirt     -match $wpf.TextBox_Skirt.Text     -and
            $_.Uniform   -match $wpf.TextBox_Uniform.Text   -and
            $_.Sleeve    -match $wpf.TextBox_Sleeve.Text    -and
            $_.NSFW      -match $wpf.TextBox_NSFW.Text      -and
            $_.Mood      -match $wpf.TextBox_Mood.Text      -and
            $_.Subject   -match $wpf.TextBox_Subject.Text   -and
            $_.Gender    -match $wpf.TextBox_Gender.Text    -and
            $_.Time      -match $wpf.TextBox_Time.Text      -and
            $_.Author    -match $wpf.TextBox_Author.Text    -and
            $_.Remarks   -match $wpf.TextBox_Remarks.Text
        ) {
            $global:csvSearch.Add($_)
        }
    })

    # Display Result
    $wpf.CSVGrid.ItemsSource = $csvSearch
}

function Invoke-ChangeRow {}

function Export-Configuration {}

function Import-Configuration {}

