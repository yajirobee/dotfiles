#
# functions
#
function source_if_exist() {
    local SRC=$1
    if [ -f "${SRC}" ]; then
        source "${SRC}"
    fi
}

#
# set complete
#

autoload -U compinit
compinit

setopt list_packed
setopt auto_pushd
setopt correct
setopt magic_equal_subst
setopt print_eight_bit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
eval `dircolors`
zstyle ':completion:*:default' list-colors ${LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

#
# set LANG
#

#export LANG=ja_JP.UTF-8
export LANG=C

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
    PROMPT=$'%B%{\e[32m%}%n@%m%{\e[m%}:%B%{\e[34m%}%~%{\e[m%}%1v\n%(!.#.$) '
else
    PROMPT=$'%B%{\e[32m%}%n@%m%{\e[m%}:%B%{\e[34m%}%~%{\e[m%}\n%(!.#.$) '
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

#
# set alias
#
source_if_exist ${HOME}/etc/aliases

# load local zsh setup
source_if_exist $HOME/.zshrc.$(hostname -s)
