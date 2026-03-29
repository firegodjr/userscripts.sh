#!/bin/bash
# Main entrypoint for userscripts

ENTRYPOINT="${BASH_SOURCE[0]}"
export USERSCRIPT_DIR=$(dirname $ENTRYPOINT)
export PATH="$PATH:$USERSCRIPT_DIR/bin"

# Set our cwd to the repo
pushd "$USERSCRIPT_DIR" > /dev/null || exit

# Set up shell
source ./bash_aliases.sh

popd > /dev/null
