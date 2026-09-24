# Codex shared configurations

Codex-specific settings and skills belong here.
`make deploy` links the following files and directories:
- `rules/default.rules` to `~/.codex/rules/default.rules`
  - Keep machine-specific rules in `~/.codex/rules/local.rules`
- Skills to `~/.codex/skills/`
- coding-agent-neutral instructions in the parent `AGENTS.md` to `~/.codex/AGENTS.md`
