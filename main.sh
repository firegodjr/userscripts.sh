#!/bin/bash
# Main entrypoint for userscripts
# Set our cwd to the repo
ENTRYPOINT="${BASH_SOURCE[0]}"
export USERSCRIPT_DIR=$(dirname $ENTRYPOINT)
pushd "$USERSCRIPT_DIR" > /dev/null || exit

source ./bash_aliases.sh

popd > /dev/null
