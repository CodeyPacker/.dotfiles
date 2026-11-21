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

# Oh My Zsh git plugin parity
function gst { git status @args }
function gcmsg { git commit -m @args }

# Docker
function dc { docker compose @args }
function dcr { docker compose run --rm @args }
function dcrp { docker compose run --rm --service-ports --use-aliases @args }
function dce { docker compose exec @args }

# Yarn
function yc { yarn clean }
function yd { yarn develop }
function yr { yarn refresh }
function ycyd { yarn clean && yarn develop }
function ycys { yarn clean && yarn serve }

# Tmux
function ta { tmux attach -t @args }
function tnew { tmux new -s @args }
function tls { tmux ls @args }
function tkill { tmux kill-session -t @args }
function tkillall { tmux kill-server }

function ll { Get-ChildItem -Force @args }

# Light or dark mode on this computer: theme, theme light|dark|toggle
function theme { & (Join-Path $dotfilesRoot "theme\theme.ps1") @args }

# Before each prompt, Starship gets the palette for the saved mode. Its palette is set in the
# config file, so light mode uses a copy of starship.toml with only the palette line changed.
function Invoke-Starship-PreCommand {
  $modeFile = Join-Path $HOME ".config\theme-mode"
  $mode = if (Test-Path -LiteralPath $modeFile) { ([IO.File]::ReadAllText($modeFile)).Trim() } else { "" }
  if ($mode -eq "light" -and (Test-Path -LiteralPath $starshipConfig)) {
    $light = Join-Path $HOME ".cache\starship-light.toml"
    if (-not (Test-Path -LiteralPath $light) -or (Get-Item $light).LastWriteTime -lt (Get-Item $starshipConfig).LastWriteTime) {
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $light) | Out-Null
      $text = [IO.File]::ReadAllText($starshipConfig)
      [IO.File]::WriteAllText($light, [regex]::Replace($text, '(?m)^palette = "preview"$', 'palette = "preview_light"'))
    }
    $env:STARSHIP_CONFIG = $light
  } else {
    $env:STARSHIP_CONFIG = $starshipConfig
  }
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Auto-cd: typing a bare directory name (no `cd` in front) switches to it,
# mirroring zsh's AUTO_CD so it feels closer to a Mac terminal.
$ExecutionContext.InvokeCommand.CommandNotFoundAction = {
  param($CommandName, $EventArgs)
  if (Test-Path -LiteralPath $CommandName -PathType Container) {
    $EventArgs.CommandScriptBlock = { Set-Location -LiteralPath $CommandName }.GetNewClosure()
    $EventArgs.StopSearch = $true
  }
}

$localProfile = Join-Path $HOME ".config\dotfiles\powershell.local.ps1"
if (Test-Path -LiteralPath $localProfile) {
  . $localProfile
}
