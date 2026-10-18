#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
test_root="$(mktemp -d)"
trap '/bin/rm -rf -- "$test_root"' EXIT

fixture_repo="$test_root/repo"
home="$test_root/home"
skills_source="$fixture_repo/dotfiles/codex/skills"
skills_dest="$home/.codex/skills"
deploy="$fixture_repo/etc/deploy.sh"
clean="$fixture_repo/etc/clean.sh"
rules_source="$fixture_repo/dotfiles/codex/rules/default.rules"
rules_dest="$home/.codex/rules/default.rules"
rules_snapshot="$home/.codex/.dotfiles-default.rules"

fail() {
	printf 'FAIL: %s\n' "$*" >&2
	exit 1
}

assert_link() {
	local expected="$1"
	local path="$2"
	[[ -L "$path" ]] || fail "expected symlink: $path"
	[[ "$(readlink "$path")" == "$expected" ]] || fail "unexpected symlink target: $path"
}

assert_absent() {
	[[ ! -e "$1" && ! -L "$1" ]] || fail "expected path to be absent: $1"
}

assert_copy() {
	[[ -f "$2" && ! -L "$2" ]] || fail "expected regular file: $2"
	cmp -s "$1" "$2" || fail "unexpected file content: $2"
}

mkdir -p \
	"$fixture_repo/etc/test" \
	"$fixture_repo/dotfiles/codex/rules" \
	"$fixture_repo/dotfiles/codex/skills/alpha" \
	"$fixture_repo/dotfiles/codex/skills/beta" \
	"$fixture_repo/common" \
	"$home/.codex/rules" \
	"$skills_dest/alpha/legacy/nested"
cp "$repo_root/etc/deploy.sh" "$deploy"
cp "$repo_root/etc/clean.sh" "$clean"
cp "$repo_root/dotfiles/AGENTS.md" "$fixture_repo/dotfiles/AGENTS.md"
cp "$repo_root/dotfiles/.bashrc" "$fixture_repo/dotfiles/.bashrc"
cp "$repo_root/dotfiles/codex/rules/default.rules" "$fixture_repo/dotfiles/codex/rules/default.rules"
cp "$repo_root/dotfiles/codex/skills/pr-review-fix-loop/SKILL.md" \
	"$fixture_repo/dotfiles/codex/skills/alpha/SKILL.md"
cp "$repo_root/dotfiles/codex/skills/pr-review-fix-loop/SKILL.md" \
	"$fixture_repo/dotfiles/codex/skills/beta/SKILL.md"
cp "$repo_root/dotfiles/codex/README.md" "$home/.codex/rules/local.rules"
ln -s "$skills_source/alpha/SKILL.md" "$skills_dest/alpha/legacy/nested/SKILL.md"

mkdir -p "$test_root/external-skill"
ln -s "$test_root/external-skill" "$skills_dest/external"

HOME="$home" "$deploy" "$fixture_repo/dotfiles/.bashrc" "$fixture_repo/common" >/dev/null
assert_link "$fixture_repo/dotfiles/.bashrc" "$home/.bashrc"
assert_link "$fixture_repo/common" "$home/common"
assert_link "$fixture_repo/dotfiles/AGENTS.md" "$home/.codex/AGENTS.md"
assert_copy "$rules_source" "$rules_dest"
assert_copy "$rules_source" "$rules_snapshot"
assert_link "$skills_source/alpha" "$skills_dest/alpha"
assert_link "$skills_source/beta" "$skills_dest/beta"
assert_link "$test_root/external-skill" "$skills_dest/external"
cmp -s "$repo_root/dotfiles/codex/README.md" "$home/.codex/rules/local.rules" || fail "deploy changed local.rules"

# Repeated deployments and source updates must replace only unchanged copies.
HOME="$home" "$deploy" >/dev/null
assert_copy "$rules_source" "$rules_dest"
printf '\n# Updated shared rules\n' >> "$rules_source"
HOME="$home" "$deploy" >/dev/null
assert_copy "$rules_source" "$rules_dest"
assert_copy "$rules_source" "$rules_snapshot"

# Cleanup must recognize the last deployment even after the source changes.
printf '\n# Not yet deployed\n' >> "$rules_source"
HOME="$home" "$clean" "$fixture_repo/dotfiles/.bashrc" "$fixture_repo/common" >/dev/null
assert_absent "$home/.bashrc"
assert_absent "$home/common"
assert_absent "$home/.codex/AGENTS.md"
assert_absent "$home/.codex/rules/default.rules"
assert_absent "$rules_snapshot"
assert_absent "$skills_dest/alpha"
assert_absent "$skills_dest/beta"
assert_link "$test_root/external-skill" "$skills_dest/external"
cmp -s "$repo_root/dotfiles/codex/README.md" "$home/.codex/rules/local.rules" || fail "clean changed local.rules"

# Migrate the old symlink without modifying its source.
ln -s "$rules_source" "$rules_dest"
cp "$rules_source" "$test_root/rules-before-migration"
HOME="$home" "$deploy" >/dev/null
assert_copy "$test_root/rules-before-migration" "$rules_source"
assert_copy "$rules_source" "$rules_dest"
assert_copy "$rules_source" "$rules_snapshot"

# Local edits must survive both deployment and cleanup.
printf '\n# Local edit\n' >> "$rules_dest"
cp "$rules_dest" "$test_root/edited-rules"
if HOME="$home" "$deploy" >/dev/null 2>&1; then
	fail "deploy accepted locally edited rules"
fi
assert_copy "$test_root/edited-rules" "$rules_dest"
assert_copy "$rules_source" "$rules_snapshot"
HOME="$home" "$clean" >/dev/null 2>&1
assert_copy "$test_root/edited-rules" "$rules_dest"
assert_copy "$rules_source" "$rules_snapshot"
assert_copy "$repo_root/dotfiles/codex/README.md" "$home/.codex/rules/local.rules"

# Once local edits are moved out, deployment and cleanup work again.
mv "$rules_dest" "$test_root/saved-local-rules"
HOME="$home" "$deploy" >/dev/null
assert_copy "$rules_source" "$rules_dest"
HOME="$home" "$clean" >/dev/null
assert_absent "$rules_dest"
assert_absent "$rules_snapshot"

# Cleanup remains compatible with the previous symlink deployment.
ln -s "$rules_source" "$rules_dest"
HOME="$home" "$clean" >/dev/null
assert_absent "$rules_dest"

rules_conflict_home="$test_root/rules-conflict-home"
mkdir -p "$rules_conflict_home/.codex/rules"
cp "$repo_root/dotfiles/codex/README.md" "$rules_conflict_home/.codex/rules/default.rules"
if HOME="$rules_conflict_home" "$deploy" "$fixture_repo/dotfiles/.bashrc" >/dev/null 2>&1; then
	fail "deploy accepted an existing unrelated rules file"
fi
cmp -s "$repo_root/dotfiles/codex/README.md" "$rules_conflict_home/.codex/rules/default.rules" || fail "deploy changed an unrelated rules file"
assert_absent "$rules_conflict_home/.bashrc"
HOME="$rules_conflict_home" "$clean" >/dev/null 2>&1
assert_copy "$repo_root/dotfiles/codex/README.md" "$rules_conflict_home/.codex/rules/default.rules"

# Never replace or remove another symlink, even with matching contents.
rules_link_home="$test_root/rules-link-home"
mkdir -p "$rules_link_home/.codex/rules"
cp "$rules_source" "$test_root/external.rules"
ln -s "$test_root/external.rules" "$rules_link_home/.codex/rules/default.rules"
if HOME="$rules_link_home" "$deploy" >/dev/null 2>&1; then
	fail "deploy accepted an unrelated rules link"
fi
HOME="$rules_link_home" "$clean" >/dev/null 2>&1
assert_link "$test_root/external.rules" "$rules_link_home/.codex/rules/default.rules"
assert_copy "$rules_source" "$test_root/external.rules"

# A snapshot symlink must never redirect writes or establish file ownership.
snapshot_home="$test_root/snapshot-home"
mkdir -p "$snapshot_home/.codex/rules"
cp "$rules_source" "$snapshot_home/.codex/rules/default.rules"
ln -s "$test_root/external.rules" "$snapshot_home/.codex/.dotfiles-default.rules"
if HOME="$snapshot_home" "$deploy" >/dev/null 2>&1; then
	fail "deploy accepted a snapshot symlink"
fi
HOME="$snapshot_home" "$clean" >/dev/null 2>&1
assert_copy "$rules_source" "$snapshot_home/.codex/rules/default.rules"
assert_link "$test_root/external.rules" "$snapshot_home/.codex/.dotfiles-default.rules"
assert_copy "$rules_source" "$test_root/external.rules"

skill_conflict_home="$test_root/skill-conflict-home"
mkdir -p "$skill_conflict_home/.codex/skills"
ln -s "$test_root/external-skill" "$skill_conflict_home/.codex/skills/alpha"
if HOME="$skill_conflict_home" "$deploy" >/dev/null 2>&1; then
	fail "deploy accepted an unrelated skill link"
fi
assert_link "$test_root/external-skill" "$skill_conflict_home/.codex/skills/alpha"

printf '%s\n' 'deploy/clean regression tests passed'
