# pyenv
export PYENV_ROOT=${HOME}/.pyenv
path=(
    ${PYENV_ROOT}/bin(N-/)
    $path
)
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi
