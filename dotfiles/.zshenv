export PYENV_ROOT=${HOME}/.pyenv

# make path list unique
# http://zsh.sourceforge.net/Guide/zshguide02.html#l24
typeset -U path

path=(
    ${HOME}/common/bin(N-/)
    ${HOME}/local/bin(N-/)
    ${HOME}/.local/bin(N-/)
    ${PYENV_ROOT}/bin(N-/)
    ${HOME}/.rbenv/bin(N-/)
    ${HOME}/.jenv/bin(N-/)
    $path
)
