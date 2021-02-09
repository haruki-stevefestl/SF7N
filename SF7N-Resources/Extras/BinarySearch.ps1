if ($null -eq $csv) {
    Write-Host 'Run Import-CustomCSV before running this script'
    exit
}

# Binary search for leftmost column of CSV
$key = Read-Host "Enter search $($csvHeader[0])"

$l = 0
$r = $csv.Count - 1

while ($l -ne $r) {
    $m = [Math]::Ceiling(($l + $r)/ 2)

    if ($csv[$m].($csvHeader[0]) -gt $key) {
        $r = $m - 1
    } else {
        $l = $m
    }
}

if ($csv[$l].($csvHeader[0]) -eq $key) {
    Write-Host "Found at $l"
} else {
    Write-Host 'Not found'
}