#Requires -Version 7

foreach ($file in (Get-ChildItem "$PSScriptRoot/Public/*.ps1" -ErrorAction Stop)) {
    . $file.FullName
}
