function Invoke-ChangeRow {
    param (
        [ValidateSet('InsertBelow', 'InsertAbove', 'InsertLast', 'RemoveAt')]
        [String] $Action,
        [Int] $At,
        [Int] $Count
    )
}
