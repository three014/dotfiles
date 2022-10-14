#!/bin/bash

sudo apt update
sudo apt install neovim
sudo apt install python3-neovim
sudo apt install ranger
sudo apt install git
sudo apt install zsh


# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k


# install nodejs
curl -sL install-node.vercel.app/lts | bash
