#!/bin/bash
################################################################################
# setup.sh
#
# Run './setup.sh' to intall dotfiles into $HOME.
#
# Author: Ryan Jacobs <ryan.mjacobs@gmail.com>
# October 03, 2014 -> File creation.
# January 20, 2015 -> Add .toprc
# Febuary 18, 2015 -> Refactor script; it looks so much cleaner!
#   March 08, 2015 -> Fix 'ln -s' bug. Use BASH not just any shell.
################################################################################

dir="$(pwd)"

show_help() {
    echo -e "Usage: $0 [-h] [-fuc]\n"
    echo "  -h    Show this help message."
    echo "  -f    Force install."
    echo "  -u    Install *all* config files."
    echo "  -c    Copy files instead of using symlinking."
    echo -e "\nReport bugs to <ryan.mjacobs@gmail.com>."
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
    ".Xresources"\
    ".gitconfig"\
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

    ".config/dunst/dunstrc"\
    .bin/*\
)

# What array will we use?
if [ $full == "true" ]; then
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

# Update Vundle packages
if type vim &>/dev/null; then
    vim -c BundleInstall -c qa
fi
