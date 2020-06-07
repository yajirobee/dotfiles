export PYENV_ROOT=${HOME}/.pyenv
path=(
    ${PYENV_ROOT}/bin(N-/)
    ${HOME}/.rbenv/bin(N-/)
    ${HOME}/.jenv/bin(N-/)
    $path
)

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

