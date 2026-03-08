
# Atomic
# Distrobox
alias dbe="distrobox enter"
alias dbc="distrobox create -i devbase --name"
alias dbl="distrobox list"
alias db="distrobox"
# Ostree
alias os="ostree"
alias ros="rpm-ostree"

# Neovim
alias v="nvim"
alias va="pushd $USERSCRIPT_DIR;nvim ./bash_aliases.sh;popd;source $USERSCRIPT_DIR/bash_aliases.sh"
alias nvim-update="pushd $NVIM_CONFIG; git pull; popd"
alias nvim-update-force="pushd $NVIM_CONFIG; git reset --hard HEAD; git pull; popd"

# Utilities
alias lg="lazygit"
alias ldr="lazydocker"

