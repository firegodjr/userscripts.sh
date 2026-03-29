#!/bin/sh

# Warn if important dirs don't exist
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "CHECKHEALTH: SCRIPTS_DIR doesn't exist: $SCRIPTS_DIR"
    exit 1
fi

if [ ! -d "$LOGS_DIR" ]; then
    echo "CHECKHEALTH: LOGS_DIR doesn't exist: $LOGS_DIR"
    exit 1
fi

# Warn if nvim doesn't exist
if [ ! -x "$(command -v nvim)" ]; then
    echo "CHECKHEALTH: nvim not installed!"
    exit 1
fi
