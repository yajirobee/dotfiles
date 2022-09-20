#
# functions
#
function source_if_exist() {
    local SRC=$1
    [ -f "${SRC}" ] && source "${SRC}"
}

#
# set complete
#

# homebrew completion
if command -v brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

autoload -Uz compinit
compinit -i

setopt list_packed
setopt auto_pushd
setopt correct
setopt magic_equal_subst
setopt print_eight_bit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

if command -v dircolors > /dev/null 2&>1; then
    eval $(dircolors)
    zstyle ':completion:*:default' list-colors ${LS_COLORS}
else
    export CLICOLOR=1
    export LSCOLORS=gxfxcxdxbxegedabagacad
    zstyle ':completion:*:default' list-colors ''
fi

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

#
# set LANG
#

#export LANG=ja_JP.UTF-8
export LANG=C
export LC_MESSAGES=C

#
# set prompt
#

if [[ $ZSH_VERSION == (<5->|4.<4->|4.3.<10->)* ]]; then
    autoload -Uz vcs_info
    precmd() {
        psvar=()
        LANG=en_US.UTF-8 vcs_info
        [[ -n "$vcs_info_msg_0_" ]] && psvar[1]=$vcs_info_msg_0_
    }
    PROMPT=$'%B%F{green}%n@%m%F{white}:%F{cyan}%~%b%F{white}%1v%f\n%(!.#.$) '
else
    PROMPT=$'%B%F{green}%n@%m%F{white}:%F{cyan}%~%b%f\n%(!.#.$) '
fi
PROMPT2="%B%_>%b "
SPROMPT="%r is correct? [n,y,a,e]: "

#setopt transient_rprompt

#
# set history
#

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # share command history data
setopt hist_reduce_blanks

# make less more friendly for non-text input files
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

#
# set alias
#
source_if_exist ${HOME}/common/aliases

PYTHONSTARTUP=${HOME}/common/pythonstartup.py
[[ -f "$PYTHONSTARTUP" ]] && export PYTHONSTARTUP

PYTHONLIB=${HOME}/common/lib/python
[[ -d "${PYTHONLIB}" ]] && export PYTHONPATH="${PYTHONLIB}${PYTHONPATH:+:}${PYTHONPATH}"

# for gnu screen
if command -v pbcopy > /dev/null 2&>1; then
    export copy_cmd="pbcopy < /tmp/screen-exchange"
elif command -v xsel > /dev/null 2&>1; then
    export copy_cmd="xsel -i -b < /tmp/screen-exchange; xsel -i -p < /tmp/screen-exchange"
fi
[[ ! -f /tmp/screen-exchange ]] && touch /tmp/screen-exchange

#
# completion
#
if command -v pipenv > /dev/null 2&>1; then
    eval "$(_PIPENV_COMPLETE=zsh_source pipenv)"
fi

#
# setup language version managers
#

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# rbenv
if command -v rbenv 1>/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

# jenv
if command -v jenv 1>/dev/null 2>&1; then
    eval "$(jenv init -)"
fi

# load local zsh setup
[[ ! -f $HOME/.zshrc.local ]] && touch $HOME/.zshrc.local
source_if_exist $HOME/.zshrc.local
source_if_exist $HOME/.zshrc.$(hostname -s)
