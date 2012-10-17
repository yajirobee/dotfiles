# ~/.bashrc: executed by bash for non-login shells.

#
# set enviromental variables
#

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
   export PATH="$HOME/bin:$PATH"
fi

# load local environment setup
if [ -f "$HOME/.localenvs" ]; then
    source "$HOME/.localenvs"
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# load local bash setup
if [ -f "$HOME/.bashrc_local" ]; then
    source "$HOME/.bash_local"
fi

export PYTHONSTARTUP=~/.pythonstartup.py

# if zsh is available use that
if which zsh > /dev/null; then
    zsh
fi
