#!/usr/bin/env bash
# install.sh: Install or reinstall scripts.
# This script aims to be nearly idempotent and should be safe to run multiple times.

set -o errexit -o pipefail -o nounset

cd

PATH=$PATH:~/dotfiles/bin

DOTLINKS=(
	bashrc
	gitconfig
	profile
	tmux.conf
	tmux.conf.user
	zshenv
	zshrc
	zshrc.local
)

STOW=(
	nvim
)

DOTDIR_ABSOLUTE=~/dotfiles
DOTDIR=dotfiles
READLINK=readlink

if [[ $OSTYPE = darwin* ]]; then
	READLINK=greadlink
fi

backup_mv() {
	local target
	target="$1.backup$(date +%s)"
	echo "NOTICE: $1 will be renamed to $target"
	mv -n "$1" "$target"
}

dotlink() {
	local source link
	source=$1
	if [[ $# -eq 2 ]]; then
		link=$2
	else
		link=~/.${source#.}
	fi

	source=$DOTDIR/$source

	echo "INFO: Linking $link -> $source"
    if [[ -L "$link" ]]; then
		local expected_target target
		expected_target="$($READLINK -e "$source")"
		target="$($READLINK -e "$link")"
		if [[ $target = "$expected_target" ]]; then
			return 0
		fi

		echo "NOTICE: $link points to $target. Retargeting"
		backup_mv "$link"
	elif [[ -e "$link" ]]; then
		echo "NOTICE: $link exists. Retargeting"
		backup_mv "$link"
	fi

	ln -s "$source" "$link"
}

# Initialize dotfiles from Dropbox (could be another source)
if [[ ! -d ~/dotfiles ]]; then
	echo "INFO: Creating dotfiles link"
	ln -s Dropbox/dotfiles ~/
fi

# Stow: helps with complex directory structures
echo "INFO: Creating stow links"
stow -v -d ~/dotfiles/stow -t ~ -S ${STOW[@]} || {
	echo "ERROR: errors encountered while running stow; continuing"
}

for item in ${DOTLINKS[@]}; do
	dotlink "$item"
done

echo "INFO: Installing Python scripts"
~/dotfiles/python/deps-install
