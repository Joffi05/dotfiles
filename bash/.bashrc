# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# Path changes
export PATH="$HOME/.local/bin:$PATH"

export EDITOR="nvim"
export VISUAL="nvim"

alias ls='ls --color=auto'
alias ll="ls -la --color=auto"

alias ra="ranger"


PS1='[\u@\h \W]\$ '


. "$HOME/.cargo/env"
