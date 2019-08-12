#!/usr/bin/env zsh
set -e
source ~/.zshrc && true

sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   bionic \
   stable"

# $(lsb_release -cs) replace bionic on CE 19.0 release
# sudo apt-add-repository --yes --update ppa:ansible/ansible

last_update=$(stat -c %Y /var/cache/apt/pkgcache.bin)
now=$(date +%s)
if [ $((now - last_update)) -gt 3600 ]; then
  sudo apt-get update
fi

sudo apt-get install \
  git \
  zsh \
  nfs-common cifs-utils \
  build-essential \
  autoconf automake libtool pkg-config \
  xsel \
  grc \
  coreutils \
  silversearcher-ag \
  tmux \
  python3-distutils \
  python3-dev \
  python3 \
  vim \
  exuberant-ctags \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  ansible


sudo chsh -s /usr/bin/zsh $USER

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

[ ! -d ~/.rbenv ] && git clone https://github.com/rbenv/rbenv.git ~/.rbenv
[ ! -d ~/.rbenv/plugins ] && (
  mkdir -p "$(rbenv root)"/plugins
  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
)

if [ ! $(which pip) ]; then
  echo "Installing PIP"
  curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
  python3 /tmp/get-pip.py --user
fi

if [ ! $(which pipenv) ]; then
  pip install --user pipenv poetry
fi

mkdir -p ~/.config/Code/User

ln -sf $ZSH/vscode/settings.json ~/.config/Code/User/settings.json
# ln -s $ZSH/vscode/keybindings.json ~/.config/Code/User/keybindings.json
#ln -s $ZSH/vscode/snippets ~/.config/Code/User/snippets

