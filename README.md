Dotfiles for my macOS setup: zsh + Neovim + WezTerm + Herdr + tmux + kitty + starship, managed with Homebrew and an install script that symlinks everything into place.

## Highlights
- Zsh with Oh My Zsh, Powerlevel10k prompt, autosuggestions, and starship for shell info.
- Neovim (Lazy-managed) with Snacks (picker/explorer/terminal), Harpoon file marks, Rosé Pine Moon, LSP formatting, and Which-Key hints.
- WezTerm and Neovim share Rosé Pine Moon, Hack Nerd Font, transparent backgrounds, and subdued inactive windows.
- Herdr provides persistent, agent-aware workspaces and panes while the original tmux and Kitty configs remain available.
- Homebrew bundle (`Brewfile`) installs the CLI tools, WezTerm, Herdr, Kitty, and Hack Nerd Font.

## Quick install
```bash
git clone https://github.com/codeypacker/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```
The script will:
- Install Oh My Zsh + Powerlevel10k if missing.
- Install Homebrew (if needed) and run the repository's `Brewfile`.
- Symlink configs into `~/.config` and your home directory (zsh, Neovim, tmux, Kitty, WezTerm, Herdr, Starship, and fonts).

> Note: install.sh assumes macOS and will overwrite existing configs it manages (zshrc, Neovim, tmux, Kitty, WezTerm, Herdr, Starship, and Powerlevel10k).

## Key things configured
- **Neovim**: Snacks keymaps (`<leader>ff` files, `<leader>fs` grep, `<leader>fb` buffers, `<leader>b` explorer, `<leader>tt` terminal, `<leader>tg` lazygit), Harpoon on `<leader>m`/`<leader>e`, LSP format on `<leader>fm`, mouse enabled for clicking in explorer, Rosé Pine Moon theme.
- **WezTerm**: Kun Chen-inspired frameless Rosé Pine Moon setup with 80% opacity, macOS blur, and dimmed unfocused windows.
- **Herdr**: Agent-aware pane manager using tmux-style `Ctrl-a` navigation and grouped workspaces.
- **Shell**: Zsh + Oh My Zsh + Powerlevel10k + starship prompt; autosuggestions.
- **Tmux**: Original custom tmux.conf retained as a fallback (see `tmux/tmux.conf`).
- **Kitty**: Config in `kitty/kitty.conf`; fonts linked to `~/Library/Fonts`.

## Updating
Pull latest and rerun `./install.sh` if you add new files. To refresh Homebrew packages only:
```bash
brew bundle --file Brewfile
```

## Troubleshooting
- If Homebrew isn’t on PATH, ensure `eval "$(/opt/homebrew/bin/brew shellenv)"` is in your shell startup.
- If Neovim complains about missing plugins, run `:Lazy sync`.
- For Snacks/lazygit toggle errors, confirm `lazygit` is installed (`brew install lazygit`).
