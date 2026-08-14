# CLAUDE.md

This file provides guidance to coding agents when working with code in this repository.

## Overview

Personal dotfiles managed via Makefile symlink deployment.
Files under `dotfiles/` (hidden files) and the `common/` directory are symlinked into `$HOME` with `ln -sfn`,
so **edits to files in this repo take effect immediately in the live environment**.
No redeploy needed after changing an already-deployed file.

## Commands

- `make list` — show files that will be deployed
- `make deploy` — symlink dotfiles and `common/` into `$HOME`
- `make depend` — install dependent packages (Homebrew on macOS)
- `make init` — clone spacemacs into `~/git/` and symlink `~/.emacs.d`
- `make install` — `update` (git pull) + `deploy` + `init`, then replaces the shell
- `make clean` — remove deployed symlinks from `$HOME`
- `make test` — currently inactive (no-op)

## Structure

- `dotfiles/` — configs symlinked to `$HOME` (`.zshrc`, `.zshenv`, `.vimrc`, `.screenrc`, `.spacemacs.d/`, etc.).
  - Deployment picks up `dotfiles/.??*`, so new files must start with a dot
  - `dotfiles/.emacs.d` is in `EXCLUSIONS` in the Makefile and is NOT deployed
  - `~/.emacs.d` is a symlink to the spacemacs clone created by `make init`; the active emacs config is `dotfiles/.spacemacs.d/`.
- `common/` — symlinked to `~/common` as a whole directory
  - `aliases` (sourced by shell rc)
  - `bin/` (on PATH via `.zshenv`)
    - `bin/rm` is a wrapper that moves files to `~/trash` instead of deleting
  - `lib/python/`.
- `etc/init.sh` — dispatches `depend`/`init` to OS-specific scripts in `etc/init/` selected by `$OSTYPE` (`depend_darwin.sh`, `init_linux-gnu.sh`, etc.).
  - Requires `GITPATH` env var (set by the Makefile)
  - OS-specific setup changes go in the matching pair of these scripts
