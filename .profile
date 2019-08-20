################################################################################
# .profile
#
# Author: Ryan Jacobs <ryan.mjacobs@gmail.com>
# May 18, 2014 -> File creation.
################################################################################

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Set $PATH
bin_path="$HOME/.bin:$HOME/.bin/rbin:$HOME/.local/bin"
builds_path="$HOME/builds/usr/bin"
npm_path="$(npm config get prefix 2>/dev/null)/bin"
ruby_path="$(ruby -r rubygems -e "puts Gem.user_dir" 2>/dev/null)/bin"
cabal_path="$HOME/.cabal/bin"
vivado_path="/opt/Xilinx/Vivado/2018.3/bin"
export GOPATH="$HOME/go"
go_path="$GOPATH/bin"

PATH="$bin_path:$builds_path:$PATH:$npm_path:$ruby_path:$cabal_path:$go_path:$vivado_path"
LD_LIBRARY_PATH="$HOME/builds/usr/lib:$LD_LIBRARY_PATH:$vivado_path/../lib/lnx64.o"

if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

export PATH="$HOME/.cargo/bin:$PATH"

# neat looping utilities
# examples:
#   $ 2x echo hello  $ x2 echo hello  $ x3 echo -n world
#   hello            hello            world world world
#   hello            hello
xx() { while true; do "$@"; done }
for n in {2..20}; do
    eval "${n}x() { for n in `seq -s' ' $n`; do" '$@; done }'
    eval "x${n}() { for n in `seq -s' ' $n`; do" '$@; done }'
done

#create_ssh_agent() {
#    # ssh-agent not found
#    if ! ssh-add -l; then
#        ssh_agent_fname="/tmp/ssh-agent.$(whoami)"
#
#        # agent file exists -> load it
#        if [ -e "$ssh_agent_fname" ]; then
#            source "$ssh_agent_fname"
#        fi
#
#        # agent file was invalid
#        if ! ssh-add -l; then
#            ssh-agent > "$ssh_agent_fname"
#            chmod 600 "$ssh_agent_fname"
#            source "$ssh_agent_fname"
#        fi
#    fi
#}
#create_ssh_agent &>/dev/null
if [ -z "$SSH_AGENT_PID" ]; then
    eval `ssh-agent`
fi

[ -e ~/torch/install/bin/torch-activate ] &&\
   . ~/torch/install/bin/torch-activate
