#!/bin/bash
# -*- mode: shell-script -*-
# ~/.bashrc: executed by bash(1) for non-login shells.
#
# debian style

# make scp work by checking for a tty
[ -t 0 ] || return

# clean up
unalias -a

# check terminal resize
shopt -s checkwinsize

# pretty colors
eval "$(dircolors)"

. /etc/bash_completion

# define some git helpers
# shellcheck source=bin/gitfunctions
[ -f ~/bin/gitfunctions ] && . ~/bin/gitfunctions

# emacs
export EDITOR="emacsclient -ct -a ''"

# PS1
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWDIRTYSTATE=true
export PROMPT_COMMAND='prompt_exit LX; prompt_title ; prompt_history'
if [ -f ~/.kube/config ] && test "$(command -v kubectl)" ; then
    PROMPT_COMMAND+="; prompt_k8s"
fi
if [ "$TERM" != "dumb" ]; then
    # set a fancy prompt
    export PS1='\[\e[33m\]\h'
    export PS1+='\[\e[34m\]${K8S:+[${K8S}]}'
    export PS1+='\[\e[36m\]${AWS_VAULT:+[${AWS_VAULT}]}'
    export PS1+='\[\e[35m\]($(mygitdir):$(mygitbranch))'
    export PS1+='\[\e[32m\]${LX:+\[\e[31m\]($LX)}$'
    export PS1+='\[\e[0m\] '
else
    export PS1="\\h\\$ "
fi

dir()  { ls -AlFh --color "$@"; }
dirt() { dir -rt "$@"; }
dird() { dir -d "$@"; }
rea()  { history | grep -E "${@:-}"; }
c()    { cat "$@"; }
g()    { grep -nIHE --color "$@"; }
m()    { less "$@"; }

startcontainer() {
    local S=~/git/dockerfiles/$1/$1.sh
    if [ -x "$S" ]
    then eval "$S ${2:-""} ${3:-""}"
    else echo "fail - expected this file to exist: $S"
    fi
}

base()   { startcontainer "${FUNCNAME[0]}" "${1:-"bash"}" "${2:-"~"}"; }
dotnet() { startcontainer "${FUNCNAME[0]}" "${1:-"bash"}" "${2:-"~/git"}"; }
erlang() { startcontainer "${FUNCNAME[0]}" "${1:-"bash"}" "${2:-"~/git"}"; }
dgo()    { startcontainer "${FUNCNAME[0]}" "${1:-"bash"}" "${2:-"~/git"}"; }
djava()  { startcontainer "${FUNCNAME[0]}" "${1:-"bash"}" "${2:-"~/git"}"; }
djulia() { startcontainer "${FUNCNAME[0]}" "${1:-"bash"}" "${2:-"~/git"}"; }
drust()  { startcontainer "${FUNCNAME[0]}" "${1:-"bash"}" "${2:-"~/git"}"; }
dwg2()   { startcontainer "${FUNCNAME[0]}" "${1:-"bash"}" "${2:-"~/wg2"}"; }

wg2-ssh() { ssh-agent bash -c "ssh-add ~/.ssh/id_rsa_wg2; $*"; }

prompt_exit() {
    eval "$1='$?'; [ \$$1 == 0 ] && unset $1"
}

prompt_title() {
    [ "$TERM_PROGRAM" = "Apple_Terminal" ] && printf "\\e]1;%s\\a" "$(mygitdir)"
}

prompt_history() {
    history -a
}

prompt_k8s() {
    K8S=$(grep -o "current-context.*" ~/.kube/config | cut -c18-)
}

## history
# lots of history
export HISTSIZE=9999
export HISTFILESIZE=$HISTSIZE

# agglomerate history from multiple shells
export HISTCONTROL="ignoredups"
shopt -s histappend

#the below will make all commands visible in all shells
#PROMPT_COMMAND="$PROMPT_COMMAND ; history -a ; history -c; history -r"

# multi-line commands
shopt -s cmdhist

# motd
uname -a
