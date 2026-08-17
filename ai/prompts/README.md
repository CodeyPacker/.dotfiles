# Shared AI prompts

This directory is the canonical, version-controlled home for personal AI
instructions shared across machines.

`sr_opus_5_system_prompt.md` is mirrored unchanged from
[`disler/fixing-smartass-opus-5`](https://github.com/disler/fixing-smartass-opus-5)
and remains covered by the adjacent upstream MIT license.

The installers expose this directory at `~/.config/ai-prompts` and use the
prompt as global personal guidance for:

- Claude Code: `~/.claude/CLAUDE.md`
- Codex: `~/.codex/AGENTS.md`

Project-level `CLAUDE.md` and `AGENTS.md` files continue to add more specific
instructions.
