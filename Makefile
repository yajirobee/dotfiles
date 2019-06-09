DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
GITPATH 	 := $(HOME)/git
CANDIDATES := $(wildcard dotfiles/.??*) common
EXCLUSIONS := .DS_Store .git .gitmodules .gitignore dotfiles/.emacs.d
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

purge: clean ## Remove the dot files and this repo
	-/bin/rm -rf $(DOTPATH)

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
