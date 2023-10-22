# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
	PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export LLVM_ROOT="$HOME/.local/src/llvm-project/"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

# User-specific aliases
alias firefox='firefox 1> /dev/null 2> /dev/null &'
alias config='/usr/bin/git --git-dir=/home/aaron/.cfg/ --work-tree=/home/aaron'
