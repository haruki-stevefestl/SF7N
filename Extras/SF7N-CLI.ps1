<#
    .SYNOPSIS
        Search a user-supplied CSV with specified regex $SearchTerm
        
    .PARAMETER csvPath
        The path containing the CSV file to search
    .PARAMETER search
        A string containing the filter conditions in the format of:
            "Header1:MatchValue1 Header2:MatchValue2"

    .EXAMPLE
        .\SF7N-CLI.ps1 -csvPath csv.csv -search 'ID:2021.*'
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)][String] $csvPath,
    [Parameter(Mandatory)][String] $search
)

# Read file
$csv = Get-Content $csvPath | ConvertFrom-CSV

# Parse search terms
$SearchTerm = [PSCustomObject] @{}
while (
    $search -match
    '(["'']?)(?(1)(.+?|[\S"'']+?))\1:(["'']?)(?(1)(.+?|[\S"'']+?))\3(?:\s|$)'
) {
    $searchTerm | Add-Member -MemberType NoteProperty -Name $Matches[2] -Value $Matches[4]
    $search = $search.Replace($Matches[0], '')
}

# Search
[Collections.ArrayList] $csvSearch = @()
foreach ($Entry in $csv) {
    # If notMatch, goto next iteration
    $SearchTerm.PSObject.Properties.ForEach({
        if ($Entry.($_.Name) -notmatch $_.Value) {continue}
    })

    $csvSearch.Add($Entry) | Out-Null
}

# Output
$csvSearch | Format-Table *