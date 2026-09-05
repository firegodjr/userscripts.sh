#!/bin/bash
set -euo pipefail

VERSION=${1:-"latest"}
ARCH=${2:-"x86_64"}

read -r -p "Are you sure you wish to update neovim to '$VERSION'? [y/N]" answer
case "${answer,,}" in
    y|yes)
        echo "Beginning update."
        ;;
    n|no|*)
        echo "Update cancelled."
        exit 0
        ;;
esac

pushd ~/bin/ >/dev/null

echo "Downloading nvim appimage for arch $ARCH with version $VERSION..."
wget -O nvim.tmp "https://github.com/neovim/neovim/releases/$VERSION/download/nvim-linux-$ARCH.appimage"

echo "Backing up current nvim to nvim.bak"
if [[ -e nvim ]]; then
    mv -f nvim nvim.bak
fi
mv nvim.tmp nvim
chmod +x nvim

popd
