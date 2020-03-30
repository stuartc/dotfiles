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
  ansible \
  autoconf \
  automake \
  build-essential \
  containerd.io \
  coreutils \
  curl \
  docker-ce \
  docker-ce-cli \
  exuberant-ctags \
  git \
  grc \
  libbz2-dev \
  libffi-dev \
  libncurses-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  libtool
  libtool \
  libxslt-dev \
  libyaml-dev \
  nfs-common cifs-utils \
  pkg-config \
  python3 \
  python3-dev \
  python3-distutils \
  silversearcher-ag \
  tmux \
  unixodbc-dev \
  unzip
  vim \
  xsel \
  zsh


sudo chsh -s /usr/bin/zsh $USER

#   erlang \
#   kubernetes-cli \
#   rbenv \
#   ruby-build \
#   node \
#   heroku \
#   exenv \
#   elixir-build
echo "Installing asdf"
[ ! -d ~/.nvm ] && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.6

mkdir -p ~/.config/Code/User

ln -sf $ZSH/vscode/settings.json ~/.config/Code/User/settings.json
# ln -s $ZSH/vscode/keybindings.json ~/.config/Code/User/keybindings.json
#ln -s $ZSH/vscode/snippets ~/.config/Code/User/snippets

