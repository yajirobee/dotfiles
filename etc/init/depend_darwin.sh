#! /bin/bash -x

if ! command -v brew 1> /dev/null 2&>1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update

brew install \
     screen \
     openssl \
     readline \
     sqlite3 \
     xz \
     zlib \
     ripgrep

if ! command -v emacs 1> /dev/null 2&>1; then
  brew install --cask emacs-app
fi

if ! command -v pyenv 1> /dev/null 2&>1; then
  brew install pyenv
fi

if ! command -v rbenv 1> /dev/null 2&>1; then
  brew install rbenv
fi

if ! command -v jenv 1> /dev/null 2&>1; then
  brew install jenv
fi
