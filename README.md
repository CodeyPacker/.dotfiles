# Cross-platform dotfiles

Shared terminal and editor configuration for macOS, native Windows, and WSL:

- Neovim with the same keybindings, plugins, Harpoon, and Rosé Pine Moon theme everywhere.
- WezTerm with platform-specific macOS blur or Windows Acrylic styling.
- Herdr with `Ctrl+A` prefix navigation and grouped agent panes.
- Starship with the same prompt and palette in Zsh and PowerShell.
- Machine profiles and private local overrides without hardcoded usernames or drive letters.

## Profiles

`DOTFILES_PROFILE` chooses the machine layer:

- `personal-mac` is the default on macOS.
- `personal-windows` is the default on Windows and launches the first installed WSL distribution in WezTerm.
- `work-windows` is intentionally conservative until the work machine and its policies are known.

The repository contains only portable settings. Machine-only paths belong under
`~/.config/dotfiles/`, which is outside this repository.

## macOS installation

```bash
git clone git@github.com:CodeyPacker/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer uses its own directory as the repository root, so the clone does not
have to be named `.dotfiles`. Existing managed files are moved into a timestamped
`~/.dotfiles-backup/` directory before links are created.

## Personal Windows installation

Clone the Windows copy onto an NTFS drive, normally under your Windows home folder:

```powershell
git clone git@github.com:CodeyPacker/.dotfiles.git "$HOME\.dotfiles"
Set-Location "$HOME\.dotfiles"
Set-ExecutionPolicy -Scope Process Bypass
.\install.ps1 -Profile personal-windows -InstallWSL
```

The script installs the native host tools with WinGet, installs Hack Nerd Font for
the current user, configures WezTerm/Starship/Herdr through environment variables,
adds a small loader to the PowerShell profile, and creates the Neovim config junction.
The optional `-InstallWSL` switch may request elevation and a Windows restart.

Native Windows Herdr is still preview software. To test it, add
`-InstallNativeHerdr`; otherwise use the stable Linux build inside WSL.

After WSL/Ubuntu is available, clone a second copy inside the Linux filesystem:

```bash
git clone git@github.com:CodeyPacker/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install-wsl.sh
```

Keeping Linux projects and the WSL clone under the Linux home directory avoids the
filesystem overhead of developing under `/mnt/c`.

## Future work Windows installation

Once the work machine arrives, start with the policy-safe profile:

```powershell
.\install.ps1 -Profile work-windows -SkipPackages
```

Then add only company-approved settings to
`wezterm/profiles/work-windows.lua`. Keep company paths, credentials, certificates,
and private aliases in the machine-local override files instead of Git.

## Machine-local overrides

Copy only the examples you need:

```text
wezterm/wezterm.local.lua.example     -> ~/.config/dotfiles/wezterm.local.lua
nvim/nvim.local.lua.example           -> ~/.config/dotfiles/nvim.local.lua
zsh/zsh.local.zsh.example             -> ~/.config/dotfiles/zsh.local.zsh
powershell/powershell.local.ps1.example -> ~/.config/dotfiles/powershell.local.ps1
```

Examples include selecting a particular WSL distribution, changing one machine's
font size, or defining a work-only project root.

## Useful Herdr shortcuts

Press `Ctrl+A`, release it, and then press:

- `%` for a vertical split
- `"` for a horizontal split
- `h`, `j`, `k`, or `l` to move between panes
- `c` for a new tab
- `w` for the workspace picker
- `y` for copy mode
- `?` for help and settings

## Updating

Pull the repository and rerun the installer for that operating system. Existing
correct links and junctions are left alone; changed targets are backed up first.

For Neovim plugin problems, run `:Lazy restore`. For Herdr config changes, run
`herdr server reload-config`.
