#!/bin/bash

dir="$(pwd)"

show_help() {
    echo -e "Usage: $0 [-h] [-fuc]\n"
    echo "  -h    Show this help message."
    echo "  -f    Force install."
    echo "  -u    Install *all* config files."
    echo "  -c    Copy files instead of using symlinking."
    exit 0
}

force=false
full=false
tool="ln"

# Grab arguments
while getopts "h?fuc" opt; do
    case "$opt" in
        h|\?) show_help ;;
        f)   force=true ;;
        u)    full=true ;;
        c)    tool="cp" ;;
    esac
done

# Check dependencies
echo "# Checking dependencies..."
deps=("git" "ln" "cp")
for d in ${deps[@]}; do
    if ! type "$d"; then
        echo "error: $d is required to run $0."
        exit 1
    fi
done

# Update submodules
echo -e "\n# Updating submodules..."
git submodule init
git submodule update --recursive

# Build rbin
pushd .bin/rbin
make
popd

# Create basic $HOME structure
mkdir -p "$HOME/.bin"
mkdir -p "$HOME/.config"

# Basic Install
basic_install=(\
    ".bashrc"\
    ".dir_colors"\
    ".mplayer"\
    ".mpv"\
    ".profile"\
    ".tmux.conf"\
    ".toprc"\
    ".twmrc"
    ".vim"\
    ".vimrc"\
    ".npmrc"\
    ".Xresources"\
    ".gitconfig"\

    ".gnupg/gpg-agent.conf"
)

# Full Install
full_install=(\
    ${basic_install[@]}\
    ".abcde.conf"\
    ".gemrc"\
    ".irssi"\
    ".toprc"\
    ".vnc"\
    ".xinitrc"\

    ".config/dunst"\
    ".config/mpv"\
    ".config/termite"\
    .bin/*\
)

# What array will we use?
if [ $full == "true" ]; then
    mkdir -p ~/.gnupg
    array=${full_install[@]}
else
    array=${basic_install[@]}
fi

# Copy/Symlink the files
[ "$tool" == "cp" ] && echo -e "\n# Copying files..." || echo -e "\n# Symlinking files..."
for f in ${array[@]}; do
    [ $force == "true" ] && rm -rf "$HOME/$f"

    if [ "$tool" == "cp" ]; then
        cp -rv "$(readlink -f "$f")" "$HOME/$f"
    elif [ "$tool" == "ln" ]; then
        ln -sv "$dir/$f" "$HOME/$(dirname "$f")"
    fi

    mkdir -p "$(dirname "$f")"
done

# nvim config (symlink to .vim)
mkdir -p ~/.config
ln -s ~/.vim ~/.config/nvim

# Update Vundle packages
if type vim &>/dev/null; then
    vim -c BundleInstall -c qa
fi
