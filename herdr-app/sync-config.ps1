# Copies Herdr app keybinds between this repo and the app's config folder.
#   pull (default): repo -> app
#   push:           app -> repo, run after changing a keybind in the app
# The repo file stores the home folder as {{HOME}} so it works on every machine.
[CmdletBinding()]
param(
  [ValidateSet("pull", "push")]
  [string]$Mode = "pull"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoFile = Join-Path $PSScriptRoot "keys.json"
$appDir = Join-Path $HOME ".config\herdr-app"
$appFile = Join-Path $appDir "keys.json"
$homeToken = "{{HOME}}"
# Backslashes are doubled inside JSON strings.
$homeInJson = $HOME.Replace("\", "\\")

if (-not (Test-Path -LiteralPath $appDir)) {
  Write-Host "Herdr app config folder not found, skipping keybind sync: $appDir" -ForegroundColor Yellow
  return
}

if ($Mode -eq "pull") {
  $source = $repoFile
  $target = $appFile
  $newText = [IO.File]::ReadAllText($source).Replace($homeToken, $homeInJson)
} else {
  $source = $appFile
  $target = $repoFile
  if (-not (Test-Path -LiteralPath $source)) {
    throw "No keybinds to push. Missing: $source"
  }
  $newText = [IO.File]::ReadAllText($source).Replace($homeInJson, $homeToken)
}

if ((Test-Path -LiteralPath $target) -and ([IO.File]::ReadAllText($target) -ceq $newText)) {
  Write-Host "Herdr keybinds already match: $target" -ForegroundColor Cyan
  return
}

if ($Mode -eq "pull" -and (Test-Path -LiteralPath $target)) {
  Copy-Item -LiteralPath $target -Destination "$target.bak-before-sync" -Force
}

[IO.File]::WriteAllText($target, $newText)
Write-Host "Herdr keybinds ${Mode}ed: $source -> $target" -ForegroundColor Green
