# ~/.bashrc: executed by bash for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# if zsh is available use that
if which zsh 1> /dev/null 2> /dev/null; then
    export SHELL=$(which zsh)
    exec $(which zsh)
    return
fi

#
# functions
#

function addpath() {
for i in $@; do
    if ! (echo $PATH | grep "$i" > /dev/null) && [ -d $i ]; then
        export PATH=$i:"$PATH"
    fi
done
}
export -f addpath

function source_if_exist() {
    local SRC=$1
    [ -f "${SRC}" ] && source "${SRC}"
}

#
# set history
#

HISTSIZE=10000
HISTFILESIZE=20000                 # maximu number of lines in history file
HISTCONTROL=ignoredups:ignorespace # ignore duplication command history list
                                   # ignore lines which begin with a space
shopt -s histappend  # append to the history file, don't overwrite it

#
# misc
#

export LANG=C
export LC_MESSAGES=C
# check the window size (update the values of LINES and COLUMNS)
shopt -s checkwinsize

# make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#
# set prompt
#

if [ -x /usr/bin/tput ]; then
   tput setaf 1 >&/dev/null
   # We have color support; assume it's compliant with Ecma-48 (ISO/IEC-6429)
fi

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\n\$ '

#
# set alias
#
source_if_exist ${HOME}/common/aliases

MYBIN=${HOME}/common/bin
[ -d "${MYBIN}" ] && addpath "${MYBIN}"

LOCALBIN=${HOME}/local/bin
[ -d "${LOCALBIN}" ] && addpath "${LOCALBIN}"

PYTHONSTARTUP=${HOME}/common/pythonstartup.py
[ -f "$PYTHONSTARTUP" ] && export PYTHONSTARTUP

PYTHONLIB=${HOME}/common/lib/python
[ -d "${PYTHONLIB}" ] && export PYTHONPATH="${PYTHONLIB}${PYTHONPATH:+:}${PYTHONPATH}"

# load local bash setup
source_if_exist ${HOME}/.bashrc.local
source_if_exist ${HOME}/.bashrc.$(hostname -s)
