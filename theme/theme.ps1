# Switches light and dark mode on this computer only.
#   theme              prints the mode
#   theme light|dark   sets it
#   theme toggle       switches it
#   theme apply        sets every tool to the saved mode again
# The mode is saved in ~/.config/theme-mode. That file is not in the repo, so each computer keeps its own.
# Follows the mode: the Herdr app ("appearance" in its settings.json) and Claude Code ("theme").
# Keep in step with theme.sh.
#
# sync-config.ps1 also uses two helpers, so the repo's Herdr settings never hold a mode:
#   theme.ps1 herdr-set <file>     writes the saved mode into that Herdr settings file
#   theme.ps1 herdr-strip <file>   removes the mode from it
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [ValidateSet("", "light", "dark", "toggle", "apply", "herdr-set", "herdr-strip")]
  [string]$Action = "",

  [Parameter(Position = 1)]
  [string]$File
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modeFile = Join-Path $HOME ".config\theme-mode"
$herdrSettings = Join-Path $HOME ".config\herdr-app\settings.json"
$claudeSettings = Join-Path $HOME ".claude\settings.json"

function Get-SavedMode {
  $mode = if (Test-Path -LiteralPath $modeFile) { ([IO.File]::ReadAllText($modeFile)).Trim() } else { "" }
  # No file yet, or something unexpected in it: dark, as before this script.
  if ($mode -eq "light") { "light" } else { "dark" }
}

# Herdr writes settings.json with one key per line. These edit that text instead of
# reformatting the JSON, so the rest of the file stays exactly as Herdr wrote it.
function Remove-Appearance([string]$text) {
  $text = [regex]::Replace($text, ',\s*"appearance"\s*:\s*"[a-z]*"', "")
  [regex]::Replace($text, '"appearance"\s*:\s*"[a-z]*"\s*,?\s*', "")
}

function Add-Appearance([string]$text, [string]$mode) {
  $text = Remove-Appearance $text
  $line = "`n  `"appearance`": `"$mode`"`n}`n"
  $match = [regex]::Match($text, '(\S)\s*\}\s*\z')
  if (-not $match.Success) { return $text }
  $before = if ($match.Groups[1].Value -eq "{") { "{" } else { $match.Groups[1].Value + "," }
  $text.Substring(0, $match.Index) + $before + $line
}

# Rewrites a file only when its text changes.
function Set-FileText([string]$path, [string]$text) {
  if ([IO.File]::ReadAllText($path) -ceq $text) { return }
  [IO.File]::WriteAllText($path, $text)
}

function Set-Mode([string]$mode) {
  # Herdr applies a settings.json change at once.
  if (Test-Path -LiteralPath $herdrSettings) {
    Set-FileText $herdrSettings (Add-Appearance ([IO.File]::ReadAllText($herdrSettings)) $mode)
  }
  # Claude Code draws its own colors: its dark theme is hard to read on a light terminal.
  # Only an existing "theme" line is changed. Sessions that are already open keep their theme.
  if (Test-Path -LiteralPath $claudeSettings) {
    $text = [IO.File]::ReadAllText($claudeSettings)
    Set-FileText $claudeSettings ([regex]::Replace($text, '("theme"\s*:\s*)"(light|dark)"', "`${1}`"$mode`""))
  }
}

function Save-Mode([string]$mode) {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $modeFile) | Out-Null
  [IO.File]::WriteAllText($modeFile, "$mode`n")
  Set-Mode $mode
  $mode
}

switch ($Action) {
  "" { Get-SavedMode }
  { $_ -in "light", "dark" } { Save-Mode $Action }
  "toggle" { if ((Get-SavedMode) -eq "dark") { Save-Mode "light" } else { Save-Mode "dark" } }
  "apply" { Set-Mode (Get-SavedMode) }
  "herdr-set" { Set-FileText $File (Add-Appearance ([IO.File]::ReadAllText($File)) (Get-SavedMode)) }
  "herdr-strip" { Set-FileText $File (Remove-Appearance ([IO.File]::ReadAllText($File))) }
}
