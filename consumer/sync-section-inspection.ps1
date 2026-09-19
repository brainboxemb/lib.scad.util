param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Target
)

$ErrorActionPreference = "Stop"

$Snippet = Join-Path $PSScriptRoot "section-inspection.scad"
$StartMarker = "// BEGIN lib.scad.util: section-inspection"
$EndMarker = "// END lib.scad.util: section-inspection"

if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) {
    throw "Target SCAD file not found: $Target"
}
if (-not (Test-Path -LiteralPath $Snippet -PathType Leaf)) {
    throw "Canonical snippet not found: $Snippet"
}

$ResolvedTarget = (Resolve-Path -LiteralPath $Target).Path
$ResolvedSnippet = (Resolve-Path -LiteralPath $Snippet).Path
$Content = [System.IO.File]::ReadAllText($ResolvedTarget)
$Managed = [System.IO.File]::ReadAllText($ResolvedSnippet)

$StartCount = ([regex]::Matches($Content, [regex]::Escape($StartMarker))).Count
$EndCount = ([regex]::Matches($Content, [regex]::Escape($EndMarker))).Count

if ($StartCount -ne $EndCount) {
    throw "Managed section-inspection markers are incomplete in: $Target"
}
if ($StartCount -gt 1) {
    throw "Multiple managed section-inspection blocks found in: $Target"
}

if ($StartCount -eq 0) {
    $Updated = $Content.TrimEnd([char[]](13, 10)) + [Environment]::NewLine + [Environment]::NewLine + $Managed
} else {
    $Pattern = "(?ms)^" + [regex]::Escape($StartMarker) + ".*?^" + [regex]::Escape($EndMarker) + "\r?\n?"
    $Updated = [regex]::Replace(
        $Content,
        $Pattern,
        [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $Managed },
        1
    )
}

[System.IO.File]::WriteAllText($ResolvedTarget, $Updated)
Write-Host "Synchronized section-inspection consumer block in $Target"
