#!/bin/sh

# Userscript
function checkhealth() {
    pushd $USERSCRIPT_DIR > /dev/null
    ./checkhealth.sh
    popd > /dev/null
}

# Atomic
# Distrobox
alias dbe="distrobox enter"
alias dbc="distrobox create -i devbase --name"
alias dbl="distrobox list"
alias db="distrobox"
alias h="distrobox-host-exec"
# Ostree
alias os="ostree"
alias ros="rpm-ostree"

function edit-aliases() {
    pushd $USERSCRIPT_DIR
    $EDITOR ./bash_aliases.sh
    source ./bash_aliases.sh
    popd
    echo "Aliases Refreshed."
}

function edit-system-aliases() {
    pushd ~
    $EDITOR ./.bash_aliases
    popd
    echo "Aliases Refreshed."
}

function edit-nvim-config() {
    pushd ~/.config/nvim
    $EDITOR ./init.lua
    popd
}

# Neovim
alias v=$EDITOR
alias va="edit-aliases"
alias vaa="edit-system-aliases"
alias vv="edit-nvim-config"
alias vu="$USERSCRIPT_DIR/bin/update-nvim-appimage.sh"
alias nvim-update="pushd $NVIM_CONFIG; git pull; popd"
alias nvim-update-force="pushd $NVIM_CONFIG; git reset --hard HEAD; git pull; popd"

# Utilities
alias lg="lazygit"
alias ldr="lazydocker"

alias cr="cargo run"
alias cc="cargo check"
alias ct="cargo test"
alias cb="cargo build"

alias dr="dotnet run"
alias dt="dotnet test"
dotnet-console-test() {
    dotnet test --filter "$1" -l "console;verbosity=detailed"
}
alias dtc="dotnet-console-test"
dotnet-console-test-write() {
    dotnet-console-test $1 > test_$1.txt
}
alias dtcw="dotnet-console-test-write"

declare -Ag CACHED_DOTNET_TESTS
declare -Ag CACHED_DOTNET_TESTS_TS
_dotnet_tests_completion() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local cwd="$(pwd)"
    if [[ -z ${CACHED_DOTNET_TESTS[$cwd]} || ${CACHED_DOTNET_TESTS_TS[$cwd]} -lt $((($(date +%s) - 15))) ]]; then
        CACHED_DOTNET_TESTS[$cwd]=$(dotnet test -t --no-build 2>/dev/null \
            | sed -n 's/^[[:space:]]\{1,\}\([A-Za-z_].*\)/\1/p' \
            | sed 's/(.*//' \
            | awk -F. 'NF>=2 {print $(NF-1)"."$NF}' \
            | sort -u)
        CACHED_DOTNET_TESTS_TS[$cwd]=$(date +%s)
    fi
    local tests="${CACHED_DOTNET_TESTS[$cwd]}"
    COMPREPLY=( $(compgen -W "$tests" -- "$cur") )
}
complete -F _dotnet_tests_completion dtc
complete -F _dotnet_tests_completion dtcw


alias targz="tar -xvzf"
alias ls="ls --color"

alias ":q"="exit"

alias a="$AGENT"
alias ac="$AGENT --continue"
