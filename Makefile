DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
GITPATH 	 := $(HOME)/git
CODEX_AGENTS := dotfiles/AGENTS.md
CODEX_SKILL := dotfiles/codex/skills/pr-review-fix-loop
CODEX_SKILL_SOURCE := $(abspath $(CODEX_SKILL))
CODEX_SKILL_DEST := $(HOME)/.codex/skills/pr-review-fix-loop
CANDIDATES := $(wildcard dotfiles/.??*) common
EXCLUSIONS := .DS_Store .git .gitmodules .gitignore dotfiles/.emacs.d dotfiles/.keyhac
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

.DEFAULT_GOAL := help

all:

list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val);)

depend: ## install dependent packages
	@echo '==> Start to install dependent packages.'
	@GITPATH=$(GITPATH) $(DOTPATH)/etc/init.sh depend

deploy: ## Create symlink to home directory
	@echo '==> Start to deploy dotfiles to home directory.'
	@$(foreach val, $(DOTFILES), ln -sfnv $(abspath $(val)) \
$(HOME)/$(notdir $(val));)
	@mkdir -p "$(HOME)/.codex"
	@ln -sfnv "$(abspath $(CODEX_AGENTS))" "$(HOME)/.codex/AGENTS.md"
	@mkdir -p "$(HOME)/.codex/skills"
	@set -e; \
	if [ -L "$(CODEX_SKILL_DEST)" ]; then \
		if [ "$$(readlink "$(CODEX_SKILL_DEST)")" != "$(CODEX_SKILL_SOURCE)" ]; then \
			echo "Refusing to replace unrelated Codex skill link: $(CODEX_SKILL_DEST)" >&2; exit 1; \
		fi; \
	elif [ -d "$(CODEX_SKILL_DEST)" ]; then \
		unexpected=$$(find "$(CODEX_SKILL_DEST)" -mindepth 1 ! -type d ! -type l -print -quit); \
		if [ -n "$$unexpected" ]; then echo "Refusing to alter: $$unexpected" >&2; exit 1; fi; \
		find "$(CODEX_SKILL_DEST)" -type l -print | while IFS= read -r link; do \
			source=$$(readlink "$$link"); \
			case "$$source" in "$(CODEX_SKILL_SOURCE)"/*) ;; *) echo "Refusing to alter unrelated link: $$link" >&2; exit 1;; esac; \
		done; \
		find "$(CODEX_SKILL_DEST)" -type l -print | while IFS= read -r link; do /bin/rm -v "$$link"; done; \
		find "$(CODEX_SKILL_DEST)" -depth -type d -empty -print | while IFS= read -r dir; do rmdir "$$dir"; done; \
	elif [ -e "$(CODEX_SKILL_DEST)" ]; then \
		echo "Refusing to replace existing Codex skill path: $(CODEX_SKILL_DEST)" >&2; exit 1; \
	fi
	@ln -sfnv "$(CODEX_SKILL_SOURCE)" "$(CODEX_SKILL_DEST)"

init: ## Setup environment settings
	@echo '==> Start to initialize configurations.'
	@GITPATH=$(GITPATH) $(DOTPATH)/etc/init.sh init

test: ## Test dotfiles and init scripts
	@#DOTPATH=$(DOTPATH) bash $(DOTPATH)/etc/test/test.sh
	@echo "test is inactive temporarily"

update: ## Fetch changes for this repo
	@git pull origin master

install: update deploy init ## Run make update, deploy, init
	@exec $$SHELL

clean: ## Remove the dot files
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES), /bin/rm -vrf $(HOME)/$(notdir $(val));)
	@if [ "$$(readlink "$(HOME)/.codex/AGENTS.md" 2>/dev/null)" = "$(abspath $(CODEX_AGENTS))" ]; then /bin/rm -v "$(HOME)/.codex/AGENTS.md"; fi
	@if [ -L "$(CODEX_SKILL_DEST)" ] && [ "$$(readlink "$(CODEX_SKILL_DEST)")" = "$(CODEX_SKILL_SOURCE)" ]; then \
		/bin/rm -v "$(CODEX_SKILL_DEST)"; \
	elif [ -d "$(CODEX_SKILL_DEST)" ] && [ ! -L "$(CODEX_SKILL_DEST)" ]; then \
		find "$(CODEX_SKILL_DEST)" -type l -print | while IFS= read -r link; do \
			source=$$(readlink "$$link"); \
			case "$$source" in "$(CODEX_SKILL_SOURCE)"/*) /bin/rm -v "$$link";; esac; \
		done; \
	fi

purge: clean ## Remove the dot files and this repo
	-/bin/rm -rf $(DOTPATH)

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
