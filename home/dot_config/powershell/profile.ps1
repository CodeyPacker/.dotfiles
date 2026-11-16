$env:STARSHIP_CONFIG = Join-Path $HOME ".config/starship.toml"
$env:WEZTERM_CONFIG_FILE = Join-Path $HOME ".config/wezterm/wezterm.lua"
$env:HERDR_CONFIG_PATH = Join-Path $HOME ".config/herdr/config.toml"

$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

if (Get-Command nvim -ErrorAction SilentlyContinue) {
  Set-Alias -Name vim -Value nvim
}

function Copy-GitBranch {
  $branch = git branch --show-current
  if ($branch) {
    $branch | Set-Clipboard
  }
}
Set-Alias -Name gcopy -Value Copy-GitBranch

if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}

$localProfile = Join-Path $HOME ".config\dotfiles\powershell.local.ps1"
if (Test-Path -LiteralPath $localProfile) {
  . $localProfile
}
