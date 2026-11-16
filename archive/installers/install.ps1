[CmdletBinding()]
param(
  [ValidateSet("personal-windows", "work-windows")]
  [string]$Profile = "personal-windows",
  [switch]$SkipPackages,
  [switch]$InstallWSL,
  [switch]$InstallNativeHerdr
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$dotfilesRoot = $PSScriptRoot
$backupRoot = Join-Path $HOME (".dotfiles-backup\" + (Get-Date -Format "yyyyMMdd-HHmmss"))
$localConfigRoot = Join-Path $HOME ".config\dotfiles"

function Install-WingetPackage {
  param([Parameter(Mandatory)][string]$Id)

  & winget list --id $Id --exact --accept-source-agreements *> $null
  if ($LASTEXITCODE -eq 0) {
    Write-Host "Already installed: $Id" -ForegroundColor Cyan
    return
  }

  Write-Host "Installing $Id..." -ForegroundColor Green
  & winget install --id $Id --exact --source winget `
    --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) {
    throw "winget failed to install $Id"
  }
}

function Backup-Path {
  param([Parameter(Mandatory)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return
  }

  $relative = $Path.Replace($HOME, "").TrimStart([char[]]"\/").Replace(":", "")
  $destination = Join-Path $backupRoot $relative
  $destinationParent = Split-Path -Parent $destination
  New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
  Move-Item -LiteralPath $Path -Destination $destination
  Write-Host "Backed up $Path to $destination" -ForegroundColor Yellow
}

function Set-DirectoryJunction {
  param(
    [Parameter(Mandatory)][string]$Source,
    [Parameter(Mandatory)][string]$Target
  )

  $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
  if ($item) {
    $resolvedTarget = $null
    $hasLinkType = $null -ne $item.PSObject.Properties["LinkType"]
    $hasTarget = $null -ne $item.PSObject.Properties["Target"]
    if ($hasLinkType -and $hasTarget -and $item.LinkType -and $item.Target) {
      $resolvedTarget = [System.IO.Path]::GetFullPath([string]$item.Target)
    }
    if ($resolvedTarget -eq [System.IO.Path]::GetFullPath($Source)) {
      Write-Host "Already linked: $Target" -ForegroundColor Cyan
      return
    }
    Backup-Path -Path $Target
  }

  New-Item -ItemType Directory -Path (Split-Path -Parent $Target) -Force | Out-Null
  New-Item -ItemType Junction -Path $Target -Target $Source | Out-Null
  Write-Host "Linked $Target -> $Source" -ForegroundColor Green
}

function Set-FileSymbolicLink {
  param(
    [Parameter(Mandatory)][string]$Source,
    [Parameter(Mandatory)][string]$Target
  )

  $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
  if ($item) {
    $resolvedTarget = $null
    $hasLinkType = $null -ne $item.PSObject.Properties["LinkType"]
    $hasTarget = $null -ne $item.PSObject.Properties["Target"]
    if ($hasLinkType -and $hasTarget -and $item.LinkType -eq "SymbolicLink" -and $item.Target) {
      $resolvedTarget = [System.IO.Path]::GetFullPath([string]$item.Target)
    }
    if ($resolvedTarget -eq [System.IO.Path]::GetFullPath($Source)) {
      Write-Host "Already linked: $Target" -ForegroundColor Cyan
      return
    }
    Backup-Path -Path $Target
  }

  New-Item -ItemType Directory -Path (Split-Path -Parent $Target) -Force | Out-Null
  try {
    New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
  }
  catch {
    throw "Unable to create $Target. Enable Windows Developer Mode or rerun PowerShell as Administrator. $($_.Exception.Message)"
  }
  Write-Host "Linked $Target -> $Source" -ForegroundColor Green
}

function Set-PowerShellLoader {
  $loaderPath = Join-Path $dotfilesRoot "powershell\profile.ps1"
  $profilePath = $PROFILE.CurrentUserAllHosts
  New-Item -ItemType Directory -Path (Split-Path -Parent $profilePath) -Force | Out-Null

  $content = ""
  if (Test-Path -LiteralPath $profilePath) {
    $content = Get-Content -LiteralPath $profilePath -Raw
    $backupPath = Join-Path $backupRoot "powershell-profile.ps1"
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    Copy-Item -LiteralPath $profilePath -Destination $backupPath
  }

  $content = [regex]::Replace(
    $content,
    '(?ms)^# >>> dotfiles >>>\r?\n.*?^# <<< dotfiles <<<\r?\n?',
    ''
  ).TrimEnd()

  $escapedLoaderPath = $loaderPath.Replace("'", "''")
  $managedBlock = @"
# >>> dotfiles >>>
. '$escapedLoaderPath'
# <<< dotfiles <<<
"@

  $newContent = if ($content) { "$content`r`n`r`n$managedBlock`r`n" } else { "$managedBlock`r`n" }
  Set-Content -LiteralPath $profilePath -Value $newContent -Encoding utf8
  Write-Host "Configured PowerShell profile loader: $profilePath" -ForegroundColor Green
}

function Install-HackNerdFont {
  $fontDirectory = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
  $regularFont = Join-Path $fontDirectory "HackNerdFont-Regular.ttf"
  if (Test-Path -LiteralPath $regularFont) {
    Write-Host "Hack Nerd Font is already installed" -ForegroundColor Cyan
    return
  }

  Write-Host "Installing Hack Nerd Font for the current user..." -ForegroundColor Green
  $release = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" `
    -Headers @{ "User-Agent" = "dotfiles-installer" }
  $asset = $release.assets | Where-Object { $_.name -eq "Hack.zip" } | Select-Object -First 1
  if (-not $asset) {
    throw "Hack.zip was not found in the latest Nerd Fonts release"
  }

  $temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-font-" + [guid]::NewGuid())
  $archive = Join-Path $temporaryRoot "Hack.zip"
  $expanded = Join-Path $temporaryRoot "Hack"
  New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null

  try {
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $archive
    Expand-Archive -LiteralPath $archive -DestinationPath $expanded
    New-Item -ItemType Directory -Path $fontDirectory -Force | Out-Null

    $fontNames = @(
      "HackNerdFont-Regular.ttf",
      "HackNerdFont-Bold.ttf",
      "HackNerdFont-Italic.ttf",
      "HackNerdFont-BoldItalic.ttf"
    )
    $registryPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
    New-Item -Path $registryPath -Force | Out-Null
    foreach ($fontName in $fontNames) {
      $source = Get-ChildItem -Path $expanded -Filter $fontName -Recurse | Select-Object -First 1
      if (-not $source) {
        throw "$fontName was not present in Hack.zip"
      }
      $destination = Join-Path $fontDirectory $fontName
      Copy-Item -LiteralPath $source.FullName -Destination $destination -Force
      New-ItemProperty -Path $registryPath -Name "$($source.BaseName) (TrueType)" `
        -Value $destination -PropertyType String -Force | Out-Null
    }
  }
  finally {
    Remove-Item -LiteralPath $temporaryRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}

if ($dotfilesRoot.StartsWith("\\wsl$", [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Clone the Windows copy of the repository onto an NTFS drive, not under \\wsl$."
}

if (-not $SkipPackages) {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is required. Install Microsoft's App Installer, then rerun this script."
  }

  $packageData = Import-PowerShellDataFile (Join-Path $dotfilesRoot "windows\packages.psd1")
  foreach ($package in $packageData.Packages) {
    Install-WingetPackage -Id $package
  }
  Install-HackNerdFont
}

if ($InstallWSL) {
  Write-Host "Requesting WSL installation. Windows may require a restart." -ForegroundColor Yellow
  Start-Process -FilePath "wsl.exe" -ArgumentList "--install", "-d", "Ubuntu" -Verb RunAs -Wait
}

if ($InstallNativeHerdr) {
  Write-Host "Installing the native Windows Herdr preview..." -ForegroundColor Yellow
  Invoke-Expression (Invoke-RestMethod -Uri "https://herdr.dev/install.ps1")
}

New-Item -ItemType Directory -Path $localConfigRoot -Force | Out-Null
[Environment]::SetEnvironmentVariable("DOTFILES_ROOT", $dotfilesRoot, "User")
[Environment]::SetEnvironmentVariable("DOTFILES_PROFILE", $Profile, "User")
[Environment]::SetEnvironmentVariable(
  "WEZTERM_CONFIG_FILE",
  (Join-Path $dotfilesRoot "wezterm\wezterm.lua"),
  "User"
)
[Environment]::SetEnvironmentVariable(
  "STARSHIP_CONFIG",
  (Join-Path $dotfilesRoot "starship\starship.toml"),
  "User"
)
[Environment]::SetEnvironmentVariable(
  "HERDR_CONFIG_PATH",
  (Join-Path $dotfilesRoot "herdr\config.toml"),
  "User"
)

$nvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
Set-DirectoryJunction -Source (Join-Path $dotfilesRoot "nvim") -Target $nvimTarget
$promptRoot = Join-Path $dotfilesRoot "ai\prompts"
$promptPath = Join-Path $promptRoot "sr_opus_5_system_prompt.md"
Set-DirectoryJunction -Source $promptRoot -Target (Join-Path $HOME ".config\ai-prompts")
Set-FileSymbolicLink -Source $promptPath -Target (Join-Path $HOME ".claude\CLAUDE.md")
Set-FileSymbolicLink -Source $promptPath -Target (Join-Path $HOME ".codex\AGENTS.md")
Set-PowerShellLoader

Write-Host ""
Write-Host "Windows profile '$Profile' is configured." -ForegroundColor Green
Write-Host "Open a new terminal so the environment variables take effect."
Write-Host "For the recommended Linux toolchain, clone this repository inside WSL and run ./install-wsl.sh."
