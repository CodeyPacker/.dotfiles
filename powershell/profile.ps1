$dotfilesRoot = $env:DOTFILES_ROOT
if ([string]::IsNullOrWhiteSpace($dotfilesRoot)) {
  $dotfilesRoot = Join-Path $HOME ".dotfiles"
}

$starshipConfig = Join-Path $dotfilesRoot "starship\starship.toml"
if (Test-Path -LiteralPath $starshipConfig) {
  $env:STARSHIP_CONFIG = $starshipConfig
}

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
