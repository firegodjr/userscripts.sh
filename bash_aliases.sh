
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

# Neovim
alias v="nvim"
alias va="edit-aliases"
alias nvim-update="pushd $NVIM_CONFIG; git pull; popd"
alias nvim-update-force="pushd $NVIM_CONFIG; git reset --hard HEAD; git pull; popd"

# Utilities
alias lg="lazygit"
alias ldr="lazydocker"

alias ":q"="exit"
