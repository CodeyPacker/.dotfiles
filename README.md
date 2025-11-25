Dotfiles for my macOS setup: zsh + Neovim + tmux + kitty + starship, managed with Homebrew and an install script that symlinks everything into place.

## Highlights
- Zsh with Oh My Zsh, Powerlevel10k prompt, autosuggestions, and starship for shell info.
- Neovim (Lazy-managed) with Snacks (picker/explorer/terminal), Catppuccin theme, LSP formatting, and Which-Key hints.
- Tmux config, Kitty terminal theme, and bundled developer fonts.
- Homebrew bundle (`Brewfile`) to install CLI tools (ripgrep, tmux, neovim, lazygit, etc.) and Kitty.

## Quick install
```bash
git clone https://github.com/codeypacker/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```
The script will:
- Install Oh My Zsh + Powerlevel10k if missing.
- Install Homebrew (if needed) and run `brew bundle --file Brewfile`.
- Symlink configs into `~/.config` and your home directory (zsh, nvim, tmux, kitty, starship, fonts).

> Note: install.sh assumes macOS and will overwrite existing configs it manages (zshrc, nvim, tmux, kitty, starship, Powerlevel10k).

## Key things configured
- **Neovim**: Snacks keymaps (`<leader>ff` files, `<leader>fs` grep, `<leader>fb` buffers, `<leader>b` explorer, `<leader>t` terminal, `<leader>tg` lazygit, marks on `<leader>m`/`<leader>e`), LSP format on `<leader>fm`, mouse enabled for clicking in explorer, Catppuccin theme.
- **Shell**: Zsh + Oh My Zsh + Powerlevel10k + starship prompt; autosuggestions.
- **Tmux**: Custom tmux.conf (see `tmux/tmux.conf`).
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
