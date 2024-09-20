#!/bin/bash

set -x

config() {
	git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
} 

# create directories
mkdir -p $HOME/.ssh/keys
mkdir -p $HOME/.config/systemd/user/

read -p "Enter your email. This will be used for 
creating the Git SSH Key: " email < /dev/tty

os_id=$(cat /etc/os-release | awk -F'=' '/^ID/{print $2;}' -)

cat <<EOF
-------------------------------------------------------------
          Installing dependencies to setup environment
-------------------------------------------------------------
EOF

case $os_id in
ubuntu | pop | debian)
	sudo apt install -y ninja-build gettext cmake unzip curl git \
		tmux openssh-server g++
	;;
fedora | rhel)
	sudo dnf -y install ninja-build cmake gcc make unzip gettext \
		curl git tmux util-linux-user openssh-server gcc-g++
	;;
arch | manjaro)
	sudo pacman -S --needed base-devel cmake unzip curl ninja git tmux openssh
	;;
*)
	echo "Not supported for now!"
	exit 1
	;;
esac

cat <<EOF
-------------------------------------------------------------
            Main dependencies have been installed
-------------------------------------------------------------
EOF

# SSH server
sudo systemctl start sshd.service
sudo systemctl enable sshd.service

# SSH for GitHub
cat <<EOF
-------------------------------------------------------------
                 Creating ssh key for GitHub
-------------------------------------------------------------
When prompted for a password, please choose a secure one.
You'll be prompted for it again later when we add it to ssh-agent.

EOF

ssh-keygen -t ed25519 -C "$email" -f $HOME/.ssh/git

cat <<EOF >$HOME/.config/systemd/user/ssh-agent.service
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a \$SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
systemctl --user enable ssh-agent.service
systemctl --user start ssh-agent.service
echo "AddKeysToAgent  yes" >>$HOME/.ssh/config
echo "Now adding the ssh key from earlier to ssh-agent:"
ssh-add ~/.ssh/keys/git

cat <<EOF
Before continuing, please visit https://github.com/settings/keys
and add this public key to your account:
EOF
cat ~/.ssh/keys/git.pub

read -p "After that, press any key to continue: " __unused < /dev/tty

# Dotfiles
cat <<EOF
-------------------------------------------------------------
                    Installing dotfiles
-------------------------------------------------------------
EOF
git clone --bare git@github.com:three014/dotfiles.git $HOME/.cfg
mkdir -p .config-backup
config checkout >/dev/null 2>&1
if [ $? = 0 ]; then
	echo "Checked out dotfiles"
else
	echo "Backing up conflicting dotfiles"
	config checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | xargs -I{} mv {} .config-backup/{}
	config checkout >/dev/null 2>&1
fi
config config --local status.showUntrackedFiles no
config config --local --add --bool push.autoSetupRemote true

echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> "$HOME/.bashrc"

