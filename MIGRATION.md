# Migration record

## September 2026 preview

- Branch: `migration/chezmoi`; starting worktree was clean. Changes remain
  uncommitted for review. No push, package installation, or live apply occurred.
- Active repository: `/home/falzey/Projects/.dotfiles`, with source files under
  `home/`. `~/.local/share/chezmoi` now aliases this same repository.
- Private backups and complete Linux diff/dry-run previews:
  `~/.local/share/chezmoi-migration-backups/20260923-004844/`.
  This includes the previous source Git metadata, chezmoi state/config directory,
  and the original Git and Zsh configs. No chezmoi configuration file existed;
  the new local TOML contains only `sourceDir`. Existing state was retained.
- Existing repository/managed-target symlinks: none. Historical installer links,
  junctions, package installation, and profile changes were inspected; installers
  are archived outside the managed source tree and were not executed.
- Git config: old chezmoi copy matched the live file byte-for-byte. No repository
  Git config existed. The entire file is preserved as a local Git-ignored source
  file; no identity, helper, or other settings were replaced.
- Validation: every selected file rendered for Linux (33), simulated macOS (38),
  and simulated Windows (34). Linux includes no Windows/macOS-only targets.
  `chezmoi diff --exclude scripts` and `chezmoi apply --dry-run --verbose
  --exclude scripts` succeeded using the final configuration. Rendered Zsh
  passed `zsh -n`. All live target contents remained unchanged.
- All original tracked content is retained, apart from intentional edits to the
  README, ignore rules, prompt README, Zsh, WezTerm, and PowerShell paths/settings.
  A credential-pattern scan of candidate Git files found no matches; the local
  Git config is excluded from Git.
- No unresolved merge/config conflicts. Non-Linux validation is rendering only;
  Windows PowerShell profile integration is manual, as described in the README.

Review the saved `linux.diff`, or rerun `chezmoi diff --exclude scripts`.
Apply the reviewed Linux configuration when ready:

```sh
chezmoi apply --exclude scripts
```

## November 2026 Linux follow-up

- The active checkout is now `main`; the chezmoi source is still `home/`.
- Three repository-backed links were added and applied for Lazygit, mprocs,
  and the Claude tour skill. `chezmoi verify --exclude scripts` passes.
- Herdr TUI 0.9.5 was installed in `~/.local/bin`; `herdr config check` passes.
  Its server is stopped until Herdr is launched.
- `home/dot_gitconfig` remains local and is now Git-ignored, along with
  `nvim.log`.
