param(
    [Parameter(Mandatory = $false)]
    [string]$RootPath = "C:\Users\Derecho\Desktop\LEX_PENAL\estructura_desarrollo",

    [Parameter(Mandatory = $false)]
    [string]$OutputDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan
}

function Get-PrettySize {
    param([Int64]$Bytes)

    if ($Bytes -ge 1TB) { return "{0:N2} TB" -f ($Bytes / 1TB) }
    elseif ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    elseif ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    elseif ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    else { return "$Bytes B" }
}

function Get-DirectoryTree {
    param(
        [string]$Path,
        [string]$Prefix = ""
    )

    $items = Get-ChildItem -LiteralPath $Path -Force | Sort-Object PSIsContainer -Descending, Name
    $count = $items.Count

    for ($i = 0; $i -lt $count; $i++) {
        $item = $items[$i]
        $isLast = ($i -eq $count - 1)

        $connector = if ($isLast) { "└── " } else { "├── " }
        $line = $Prefix + $connector + $item.Name
        Write-Output $line

        if ($item.PSIsContainer) {
            $childPrefix = if ($isLast) { $Prefix + "    " } else { $Prefix + "│   " }
            Get-DirectoryTree -Path $item.FullName -Prefix $childPrefix
        }
    }
}

function Get-FolderSummary {
    param([string]$FolderPath)

    if (-not (Test-Path -LiteralPath $FolderPath)) {
        return [pscustomobject]@{
            Name             = Split-Path $FolderPath -Leaf
            Exists           = $false
            FullPath         = $FolderPath
            DirectSubfolders = 0
            DirectFiles      = 0
            TotalSubfolders  = 0
            TotalFiles       = 0
            TotalSizeBytes   = 0
            TotalSizePretty  = "0 B"
        }
    }

    $allDirs  = @(Get-ChildItem -LiteralPath $FolderPath -Directory -Recurse -Force -ErrorAction SilentlyContinue)
    $allFiles = @(Get-ChildItem -LiteralPath $FolderPath -File -Recurse -Force -ErrorAction SilentlyContinue)

    $size = 0
    if ($allFiles.Count -gt 0) {
        $size = ($allFiles | Measure-Object -Property Length -Sum).Sum
    }

    return [pscustomobject]@{
        Name             = Split-Path $FolderPath -Leaf
        Exists           = $true
        FullPath         = (Resolve-Path $FolderPath).Path
        DirectSubfolders = @((Get-ChildItem -LiteralPath $FolderPath -Directory -Force -ErrorAction SilentlyContinue)).Count
        DirectFiles      = @((Get-ChildItem -LiteralPath $FolderPath -File -Force -ErrorAction SilentlyContinue)).Count
        TotalSubfolders  = $allDirs.Count
        TotalFiles       = $allFiles.Count
        TotalSizeBytes   = $size
        TotalSizePretty  = Get-PrettySize -Bytes $size
    }
}

function Get-TopExtensions {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }

    $files = @(Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue)

    if ($files.Count -eq 0) {
        return @()
    }

    return $files |
        Group-Object Extension |
        Sort-Object Count -Descending |
        Select-Object -First 15 @{
            Name = "Extension"; Expression = {
                if ([string]::IsNullOrWhiteSpace($_.Name)) { "[sin extensión]" } else { $_.Name }
            }
        }, Count
}

try {
    if (-not (Test-Path -LiteralPath $RootPath)) {
        throw "La ruta no existe: $RootPath"
    }

    $resolvedRoot = (Resolve-Path $RootPath).Path

    if ([string]::IsNullOrWhiteSpace($OutputDir)) {
        $OutputDir = Join-Path $resolvedRoot "_reportes_estructura"
    }

    if (-not (Test-Path -LiteralPath $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $txtReport  = Join-Path $OutputDir "reporte_estructura_$timestamp.txt"
    $jsonReport = Join-Path $OutputDir "reporte_estructura_$timestamp.json"

    $expectedFolders = @("docs", "src", "infra", "scripts", "tests", "resources")
    $folderSummaries = @()

    foreach ($folder in $expectedFolders) {
        $folderPath = Join-Path $resolvedRoot $folder
        $folderSummaries += Get-FolderSummary -FolderPath $folderPath
    }

    $rootDirs  = @(Get-ChildItem -LiteralPath $resolvedRoot -Directory -Recurse -Force -ErrorAction SilentlyContinue)
    $rootFiles = @(Get-ChildItem -LiteralPath $resolvedRoot -File -Recurse -Force -ErrorAction SilentlyContinue)

    $rootSize = 0
    if ($rootFiles.Count -gt 0) {
        $rootSize = ($rootFiles | Measure-Object -Property Length -Sum).Sum
    }

    $topExtensions = Get-TopExtensions -Path $resolvedRoot
    $missingFolders = @($folderSummaries | Where-Object { -not $_.Exists } | Select-Object -ExpandProperty Name)

    $treeLines = @()
    $treeLines += (Split-Path $resolvedRoot -Leaf)
    $treeLines += Get-DirectoryTree -Path $resolvedRoot

    $reportObject = [pscustomobject]@{
        Proyecto = [pscustomobject]@{
            Ruta               = $resolvedRoot
            FechaReporte       = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            TotalCarpetas      = $rootDirs.Count
            TotalArchivos      = $rootFiles.Count
            TamanoTotalBytes   = $rootSize
            TamanoTotalVisible = (Get-PrettySize -Bytes $rootSize)
        }
        CarpetasEsperadas = $folderSummaries
        CarpetasFaltantes = $missingFolders
        ExtensionesTop    = $topExtensions
        Arbol             = $treeLines
    }

    Write-Section "RUTA ANALIZADA"
    Write-Host $resolvedRoot -ForegroundColor Yellow

    Write-Section "RESUMEN GENERAL"
    Write-Host ("Carpetas totales : {0}" -f $rootDirs.Count)
    Write-Host ("Archivos totales : {0}" -f $rootFiles.Count)
    Write-Host ("Tamaño total     : {0}" -f (Get-PrettySize -Bytes $rootSize))

    Write-Section "VALIDACIÓN DE CARPETAS PRINCIPALES"
    $folderSummaries | Format-Table Name, Exists, DirectSubfolders, DirectFiles, TotalSubfolders, TotalFiles, TotalSizePretty -AutoSize

    if ($missingFolders.Count -gt 0) {
        Write-Host ""
        Write-Host "Faltan carpetas esperadas:" -ForegroundColor Red
        $missingFolders | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    }
    else {
        Write-Host ""
        Write-Host "Todas las carpetas principales existen." -ForegroundColor Green
    }

    Write-Section "EXTENSIONES MÁS FRECUENTES"
    if ($topExtensions.Count -gt 0) {
        $topExtensions | Format-Table -AutoSize
    }
    else {
        Write-Host "No se encontraron archivos."
    }

    Write-Section "ÁRBOL DE LA ESTRUCTURA"
    $treeLines | ForEach-Object { Write-Host $_ }

    $txtLines = @()
    $txtLines += "REPORTE DE ESTRUCTURA DEL PROYECTO"
    $txtLines += ("Fecha: {0}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
    $txtLines += ("Ruta : {0}" -f $resolvedRoot)
    $txtLines += ""
    $txtLines += "RESUMEN GENERAL"
    $txtLines += ("- Carpetas totales : {0}" -f $rootDirs.Count)
    $txtLines += ("- Archivos totales : {0}" -f $rootFiles.Count)
    $txtLines += ("- Tamaño total     : {0}" -f (Get-PrettySize -Bytes $rootSize))
    $txtLines += ""
    $txtLines += "CARPETAS PRINCIPALES"
    foreach ($fs in $folderSummaries) {
        $txtLines += ("- {0} | Existe: {1} | Subcarpetas directas: {2} | Archivos directos: {3} | Subcarpetas totales: {4} | Archivos totales: {5} | Tamaño: {6}" -f `
            $fs.Name, $fs.Exists, $fs.DirectSubfolders, $fs.DirectFiles, $fs.TotalSubfolders, $fs.TotalFiles, $fs.TotalSizePretty)
    }

    if ($missingFolders.Count -gt 0) {
        $txtLines += ""
        $txtLines += "CARPETAS FALTANTES"
        foreach ($mf in $missingFolders) {
            $txtLines += ("- {0}" -f $mf)
        }
    }

    $txtLines += ""
    $txtLines += "EXTENSIONES MÁS FRECUENTES"
    foreach ($ext in $topExtensions) {
        $txtLines += ("- {0}: {1}" -f $ext.Extension, $ext.Count)
    }

    $txtLines += ""
    $txtLines += "ÁRBOL"
    $txtLines += $treeLines

    $txtLines | Set-Content -LiteralPath $txtReport -Encoding UTF8
    $reportObject | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonReport -Encoding UTF8

    Write-Section "REPORTES GENERADOS"
    Write-Host $txtReport -ForegroundColor Green
    Write-Host $jsonReport -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}