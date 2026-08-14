#! /bin/bash -x

[[ -z ${GITPATH+x} ]] && echo "GITPATH must be set" && exit

# install spacemacs
if [[ ! -d ${GITPATH}/spacemacs ]]; then
    git clone --branch develop https://github.com/syl20bnr/spacemacs.git ${GITPATH}/spacemacs
fi
if [[ ! -d ${HOME}/.emacs.d ]]; then
    ln -sfnv ${GITPATH}/spacemacs ${HOME}/.emacs.d
fi

# install default python (version pinned in ~/.python-version)
if command -v uv 1> /dev/null 2>&1; then
    uv python install --default "$(cat ${HOME}/.python-version)"
fi
