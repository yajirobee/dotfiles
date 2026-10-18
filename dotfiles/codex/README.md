# Codex shared configurations

Codex-specific settings and skills belong here.
`make deploy` links:

- Skills to `~/.codex/skills/`
- coding-agent-neutral instructions in the parent `AGENTS.md` to `~/.codex/AGENTS.md`

It copies `rules/default.rules` to `~/.codex/rules/default.rules`, replacing the
previous deployment's symlink. Codex [ignores symlinked rules files](https://github.com/openai/codex/issues/16452).
Run `make deploy` after editing shared rules.

Keep machine-specific rules in `~/.codex/rules/local.rules`.
Deployment saves a copy in `~/.codex/.dotfiles-default.rules` to detect local edits.
Deploy refuses to overwrite untracked or modified rules; clean preserves them.
Both leave `local.rules` unchanged.
