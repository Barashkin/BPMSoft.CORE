<#
.SYNOPSIS
    Верификация «замкнутой энциклопедии»: целостные ссылки между .md и отсутствие «сирот».

.DESCRIPTION
    1) Битые внутренние ссылки: все target *.md должны существовать (якори не проверяются).
    2) Орфаны: любой docs/**/*.md должен быть достижим обходом графа ссылок, начиная с хабов.

.PARAMETER DocsRoot
    Корень деревьев документации (по умолчанию родитель каталога tools).
#>

[CmdletBinding()]
param(
    [string]$DocsRoot = ''
)

if ([string]::IsNullOrWhiteSpace($DocsRoot)) {
    $_toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $DocsRoot = Split-Path -Parent $_toolsDir
}

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-LinkTargets {
    param([string]$Content)
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($Content, '\]\(([^)]+)\)')) {
        $raw = $m.Groups[1].Value.Trim()
        if ($raw -match '^(https?|mailto):') { continue }
        $pathPart = ($raw -split '#', 2)[0]
        if ([string]::IsNullOrWhiteSpace($pathPart)) { continue }
        if ($pathPart -match '\.(png|gif|jpg|jpeg|webp|svg|ico)(\?|$)') { continue }
        [void]$out.Add($pathPart)
    }
    return $out
}

function Resolve-DocLink {
    param([string]$FromPath, [string]$Href)
    try {
        $dir = Split-Path -Parent $FromPath
        $combined = [System.IO.Path]::GetFullPath((Join-Path $dir $Href))
        return $combined
    } catch {
        return $null
    }
}

$hubNames = @(
    'README.md',
    'INDEX.md',
    'AGENT_INDEX.md',
    'ENCYCLOPEDIA.md',
    'DOCUMENTATION_FINAL_AUDIT.md',
    'extended\INDEX.md'
)

$broken = New-Object System.Collections.ArrayList
$allMd = Get-ChildItem -Path $DocsRoot -Filter '*.md' -Recurse -File | Where-Object {
    $_.FullName -notmatch '[\\/]node_modules[\\/]'
}
$allMdSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($f in $allMd) { [void]$allMdSet.Add($f.FullName) }

foreach ($src in $allMd) {
    $text = Get-Content -LiteralPath $src.FullName -Raw -Encoding UTF8
    foreach ($rel in (Get-LinkTargets $text)) {
        $resolved = Resolve-DocLink -FromPath $src.FullName -Href $rel
        if (-not $resolved) { continue }
        if ($resolved -match '\.[Mm][Dd]$|^[^.]+$') {
            if (-not ($resolved -match '\.[Mm][Dd]$')) {
                # treat extension-less as optional; skip weak check
                continue
            }
            if (-not (Test-Path -LiteralPath $resolved)) {
                [void]$broken.Add([pscustomobject]@{
                    Source = $src.FullName.Substring($DocsRoot.Length).TrimStart('\')
                    Target = $rel
                    Resolved = $resolved
                })
            }
        }
    }
}

# BFS from hubs
$hubPaths = @()
foreach ($h in $hubNames) {
    $p = Join-Path $DocsRoot $h
    if (Test-Path -LiteralPath $p) { $hubPaths += @( (Get-Item -LiteralPath $p).FullName ) }
}
$visited = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$queue = New-Object System.Collections.Queue
foreach ($h in $hubPaths) {
    if ($allMdSet.Contains($h)) {
        [void]$visited.Add($h)
        $queue.Enqueue($h)
    }
}
while ($queue.Count -gt 0) {
    $cur = $queue.Dequeue()
    $text = Get-Content -LiteralPath $cur -Raw -Encoding UTF8
    foreach ($rel in (Get-LinkTargets $text)) {
        $resolved = Resolve-DocLink -FromPath $cur -Href $rel
        if (-not $resolved) { continue }
        if ($resolved -notmatch '\.[Mm][Dd]$') { continue }
        if (-not $allMdSet.Contains($resolved)) { continue }
        if (-not $visited.Contains($resolved)) {
            [void]$visited.Add($resolved)
            $queue.Enqueue($resolved)
        }
    }
}

$orphans = foreach ($f in $allMd) {
    if (-not $visited.Contains($f.FullName)) {
        $f.FullName.Substring($DocsRoot.Length).TrimStart('\')
    }
}

$result = [pscustomobject]@{
    DocsRoot           = $DocsRoot
    TotalMarkdownFiles = $allMd.Count
    BrokenLinks        = $broken.Count
    Orphans            = @($orphans).Count
    BrokenDetails      = $broken
    OrphanPaths        = @($orphans)
}

Write-Output $result

if ($broken.Count -gt 0 -or @($orphans).Count -gt 0) {
    exit 1
}
exit 0
