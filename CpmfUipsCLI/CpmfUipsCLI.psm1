#Requires -Version 7

foreach ($file in (Get-ChildItem "$PSScriptRoot/Private/*.ps1" -ErrorAction Stop)) {
    . $file.FullName
}
foreach ($file in (Get-ChildItem "$PSScriptRoot/Public/*.ps1" -ErrorAction Stop)) {
    . $file.FullName
}
