#!/usr/bin/env zsh
set -e
source ~/.zshrc && true

sudo chsh -s /usr/bin/zsh $USER

last_update=$(stat -c %Y /var/cache/apt/pkgcache.bin)
now=$(date +%s)
if [ $((now - last_update)) -gt 3600 ]; then
  sudo apt-get update
fi

sudo apt-get install \
  git \
  zsh \
  build-essential \
  grc \
  coreutils \
  silversearcher-ag \
  tmux \
  curl \
  python3-distutils \
  python3 \
  vim


#   erlang \
#   kubernetes-cli \
#   rbenv \
#   ruby-build \
#   node \
#   heroku \
#   exenv \
#   elixir-build

echo "Installing NVM"
[ ! -d ~/.nvm ] && git clone https://github.com/nvm-sh/nvm.git ~/.nvm

(
  cd "$NVM_DIR"
  git fetch --tags origin
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"



if [ ! $(which pip) ]; then
  echo "Installing PIP"
  curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
  python3 /tmp/get-pip.py --user
fi

pip install --user pipenv poetry