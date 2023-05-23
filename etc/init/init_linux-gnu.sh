#! /bin/bash -x

[[ -z ${GITPATH+x} ]] && echo "GITPATH must be set" && exit

# install spacemacs
if [[ ! -d ${GITPATH}/spacemacs ]]; then
    git clone --branch develop https://github.com/syl20bnr/spacemacs.git ${GITPATH}/spacemacs
fi
if [[ ! -d ${HOME}/.emacs.d ]]; then
    ln -sfnv ${GITPATH}/spacemacs ${HOME}/.emacs.d
fi

# install pyenv
if [[ ! -d ${GITPATH}/pyenv ]]; then
    git clone https://github.com/pyenv/pyenv.git ${GITPATH}/pyenv
fi
if [[ ! -d ${HOME}/.pyenv ]]; then
    ln -sfnv ${GITPATH}/pyenv ${HOME}/.pyenv
fi

# install rbenv
RBENV_PATH=${GITPATH}/rbenv
if [[ ! -d $RBENV_PATH ]]; then
    git clone https://github.com/rbenv/rbenv.git $RBENV_PATH
fi
if [[ ! -d ${RBENV_PATH}/plugins/ruby-build ]]; then
    git clone https://github.com/rbenv/ruby-build.git ${RBENV_PATH}/plugins/ruby-build
fi
if [[ ! -d ${RBENV_PATH}/plugins/rbenv-gemset ]]; then
    git clone https://github.com/jf/rbenv-gemset.git ${RBENV_PATH}/plugins/rbenv-gemset
fi
if [[ ! -d ${HOME}/.rbenv ]]; then
    ln -sfnv ${GITPATH}/rbenv ${HOME}/.rbenv
fi
