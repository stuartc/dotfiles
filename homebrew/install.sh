#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! $(which brew)
then
  echo "  x You should probably install Homebrew first:"
  echo "    https://github.com/mxcl/homebrew/wiki/installation"
  exit
fi

# Install homebrew packages
brew install \
  git \
  grc \
  coreutils \
  spark \
  ag \
  erlang \
  kubernetes-cli \
  tmux \
  rbenv \
  ruby-build \
  node \
  heroku \
  exenv \
  elixir-build

# brew cask install flowdock skype harvest spectacle little-snitch skitch iterm2 alfred whatsapp dropbox google-chrome firefox
exit 0
