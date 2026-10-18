# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Overview

Personal dotfiles managed via Makefile symlink deployment.
Hidden files under `dotfiles/` and the `common/` directory are symlinked into `$HOME` with `ln -sfn`.
Edits to deployed symlink targets take effect immediately.

Codex rules are copied as symbolic links don't work; run `make deploy` after editing them.

## Commands

Covers only major commands. Read `Makefile` for the details.

- `make deploy` — link dotfiles and common files
- `make depend` — install system packages with Homebrew (macOS) or apt (Debian)
- `make init` — run OS-specific editor and language-tool setup
- `make install` — run `update`, `deploy`, and `init`, then replace the shell
- `make clean` — remove deployed linked entries

## Structure

- `dotfiles/` — home-directory configurations.
- `common/` — shared shell utilities.
- `etc/` — setup and regression-test scripts.
