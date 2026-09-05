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

alias targz="tar -xvzf"
alias ls="ls --color"

alias ":q"="exit"

alias a="$AGENT"
alias ac="$AGENT --continue"
