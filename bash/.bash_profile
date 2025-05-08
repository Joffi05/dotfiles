# .bash_profile
# Not needed, because login shell is nushell, but stays
if [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
fi

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

. "$HOME/.cargo/env"
