$temp = @"
ID,Viewpoint
1,Front
2,Back
"@

$wpf.CSVGrid.ItemsSource = $temp | ConvertFrom-CSV