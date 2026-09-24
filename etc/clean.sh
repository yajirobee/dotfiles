#!/usr/bin/env bash
set -euo pipefail

dotpath="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
codex_dir="$HOME/.codex"
agents_source="$dotpath/dotfiles/AGENTS.md"
rules_source="$dotpath/dotfiles/codex/rules/default.rules"
rules_dest="$codex_dir/rules/default.rules"
skills_source_dir="$dotpath/dotfiles/codex/skills"
skills_dest_dir="$codex_dir/skills"

printf '%s\n' 'Remove dot files in your home directory...'

for source in "$@"; do
	/bin/rm -vrf "$HOME/${source##*/}" || true
done

if [[ "$(readlink "$codex_dir/AGENTS.md" 2>/dev/null || true)" == "$agents_source" ]]; then
	/bin/rm -v "$codex_dir/AGENTS.md"
fi
if [[ -L "$rules_dest" && "$(readlink "$rules_dest")" == "$rules_source" ]]; then
	/bin/rm -v "$rules_dest"
fi

if [[ -d "$skills_dest_dir" ]]; then
	while IFS= read -r -d '' link; do
		source="$(readlink "$link")"
		case "$source" in
			"$skills_source_dir"/*) /bin/rm -v "$link" ;;
		esac
	done < <(find -H "$skills_dest_dir" -type l -print0)
fi
