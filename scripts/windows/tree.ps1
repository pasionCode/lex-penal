param([string]$Root = ".")
Get-ChildItem -Path $Root -Recurse | Select-Object FullName
