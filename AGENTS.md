# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Overview

Personal dotfiles managed via Makefile symlink deployment.
Files under `dotfiles/` (hidden files) and the `common/` directory are symlinked into `$HOME` with `ln -sfn`,
so **edits to files in this repo take effect immediately in the live environment**.
No redeploy needed after changing an already-deployed file.

## Commands

- `make list` — list home-level dotfiles and `common/` entries selected by the Makefile
- `make deploy` — link home-level dotfiles, `common/`, and shared Codex settings
- `make depend` — install system packages with Homebrew (macOS) or apt (Debian)
- `make init` — run OS-specific editor and language-tool setup
- `make update` — pull `origin/master` into the current branch
- `make install` — run `update`, `deploy`, and `init`, then replace the shell
- `make clean` — remove deployed home entries and shared Codex links; preserve `local.rules`
- `make purge` — run `clean`, then remove this repository
- `make test` — run deploy and clean regression tests
- `make help` — list available targets; also the default `make` target

## Structure

- `dotfiles/` — home-directory configurations.
- `common/` — shared shell utilities.
- `etc/` — setup and regression-test scripts.
