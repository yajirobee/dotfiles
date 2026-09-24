#!/usr/bin/env bash
set -euo pipefail

dotpath="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
codex_dir="$HOME/.codex"
rules_source="$dotpath/dotfiles/codex/rules/default.rules"
rules_dest="$codex_dir/rules/default.rules"
skills_source_dir="$dotpath/dotfiles/codex/skills"
skills_dest_dir="$codex_dir/skills"

printf '%s\n' '==> Start to deploy dotfiles to home directory.'

if [[ -L "$rules_dest" ]]; then
	if [[ "$(readlink "$rules_dest")" != "$rules_source" ]]; then
		printf 'Refusing to replace unrelated Codex rules link: %s\n' "$rules_dest" >&2
		exit 1
	fi
elif [[ -e "$rules_dest" ]]; then
	printf 'Refusing to replace existing Codex rules file: %s; move machine-specific rules to local.rules first\n' "$rules_dest" >&2
	exit 1
fi

while IFS= read -r -d '' skill_source; do
	if [[ ! -f "$skill_source/SKILL.md" ]]; then
		printf 'Invalid Codex skill directory (missing SKILL.md): %s\n' "$skill_source" >&2
		exit 1
	fi
done < <(find "$skills_source_dir" -mindepth 1 -maxdepth 1 -type d -print0)

for source in "$@"; do
	ln -sfnv "$source" "$HOME/${source##*/}"
done

mkdir -p "$codex_dir"
ln -sfnv "$dotpath/dotfiles/AGENTS.md" "$codex_dir/AGENTS.md"
mkdir -p "$codex_dir/rules"
ln -sfnv "$rules_source" "$rules_dest"
mkdir -p "$skills_dest_dir"

while IFS= read -r -d '' skill_source; do
	if [[ ! -f "$skill_source/SKILL.md" ]]; then
		printf 'Invalid Codex skill directory (missing SKILL.md): %s\n' "$skill_source" >&2
		exit 1
	fi

	skill_dest="$skills_dest_dir/${skill_source##*/}"
	if [[ -L "$skill_dest" ]]; then
		if [[ "$(readlink "$skill_dest")" != "$skill_source" ]]; then
			printf 'Refusing to replace unrelated Codex skill link: %s\n' "$skill_dest" >&2
			exit 1
		fi
	elif [[ -d "$skill_dest" ]]; then
		unexpected="$(find "$skill_dest" -mindepth 1 ! -type d ! -type l -print -quit)"
		if [[ -n "$unexpected" ]]; then
			printf 'Refusing to alter: %s\n' "$unexpected" >&2
			exit 1
		fi
		while IFS= read -r -d '' link; do
			source="$(readlink "$link")"
			case "$source" in
				"$skill_source"/*) ;;
				*) printf 'Refusing to alter unrelated link: %s\n' "$link" >&2; exit 1 ;;
			esac
		done < <(find "$skill_dest" -type l -print0)
		while IFS= read -r -d '' link; do
			/bin/rm -v "$link"
		done < <(find "$skill_dest" -type l -print0)
		find "$skill_dest" -depth -type d -empty -exec rmdir {} \;
		if [[ -e "$skill_dest" ]]; then
			printf 'Refusing to replace Codex skill directory with remaining content: %s\n' "$skill_dest" >&2
			exit 1
		fi
	elif [[ -e "$skill_dest" ]]; then
		printf 'Refusing to replace existing Codex skill path: %s\n' "$skill_dest" >&2
		exit 1
	fi

	ln -sfnv "$skill_source" "$skill_dest"
done < <(find "$skills_source_dir" -mindepth 1 -maxdepth 1 -type d -print0)
