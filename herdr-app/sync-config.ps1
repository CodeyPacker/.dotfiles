# Copies the Herdr app's settings files between this repo and the app's config folder.
# The app rewrites these files in place, so they are copied, not linked.
#   pull (default): repo -> app
#   push:           app -> repo, run after changing a setting, keybind or letter in the app
# Name files after the mode to copy only those, for example: sync-config.ps1 push hints.json
# The repo files store the home folder as {{HOME}} so they work on every machine.
# Keep the file list in step with sync-config.sh and .githooks/post-merge.
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [ValidateSet("pull", "push")]
  [string]$Mode = "pull",

  [Parameter(ValueFromRemainingArguments)]
  [ValidateSet("keys.json", "hints.json", "settings.json", "mods/islands-workspace-chrome/settings.json", "shared.json")]
  [string[]]$Files
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $Files) {
  $Files = @("keys.json", "hints.json", "settings.json", "mods/islands-workspace-chrome/settings.json", "shared.json")
}

$appDir = Join-Path $HOME ".config\herdr-app"
$homeToken = "{{HOME}}"
# Backslashes are doubled inside JSON strings.
$homeInJson = $HOME.Replace("\", "\\")

if (-not (Test-Path -LiteralPath $appDir)) {
  Write-Host "Herdr app config folder not found, skipping sync: $appDir" -ForegroundColor Yellow
  return
}

foreach ($file in $Files) {
  $repoFile = Join-Path $PSScriptRoot $file
  $appFile = Join-Path $appDir $file

  # Only some keys of shared.json are copied. sync-shared.mjs does that and explains why.
  if ($file -eq "shared.json") {
    if (Get-Command node -ErrorAction SilentlyContinue) {
      & node (Join-Path $PSScriptRoot "sync-shared.mjs") $Mode $repoFile $appFile
    } else {
      Write-Host "Skipping shared.json, it needs Node and node is not on PATH." -ForegroundColor Yellow
    }
    continue
  }

  if ($Mode -eq "pull") {
    $source = $repoFile
    $target = $appFile
  } else {
    $source = $appFile
    $target = $repoFile
  }

  if (-not (Test-Path -LiteralPath $source)) {
    Write-Host "Skipping $file, missing: $source" -ForegroundColor Yellow
    continue
  }

  # A mod's settings file has nowhere to go until that mod is installed.
  $targetDir = Split-Path -Parent $target
  if (-not (Test-Path -LiteralPath $targetDir)) {
    Write-Host "Skipping $file, folder missing: $targetDir" -ForegroundColor Yellow
    continue
  }

  $text = [IO.File]::ReadAllText($source)
  if ($Mode -eq "pull") {
    $newText = $text.Replace($homeToken, $homeInJson)
  } else {
    $newText = $text.Replace($homeInJson, $homeToken)
  }

  if ((Test-Path -LiteralPath $target) -and ([IO.File]::ReadAllText($target) -ceq $newText)) {
    Write-Host "Already matches: $target" -ForegroundColor Cyan
    continue
  }

  if ($Mode -eq "pull" -and (Test-Path -LiteralPath $target)) {
    Copy-Item -LiteralPath $target -Destination "$target.bak-before-sync" -Force
  }

  [IO.File]::WriteAllText($target, $newText)
  Write-Host "${Mode}ed $file`: $source -> $target" -ForegroundColor Green
}
