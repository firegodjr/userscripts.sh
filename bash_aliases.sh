
# Distrobox
alias dbe="distrobox enter"
alias dbc="distrobox create -i devbase --name"
alias dbl="distrobox list"
alias db="distrobox"

# Neovim
alias v="nvim"
alias va="pushd ~/.aliases;nvim ./bash_aliases.sh;popd;source ~/.aliases/bash_aliases.sh"
NVIM_CONFIG="$HOME/.config/nvim"
alias nvim-update="pushd $NVIM_CONFIG; git pull; popd"
alias nvim-update-force="pushd $NVIM_CONFIG; git reset --hard HEAD; git pull; popd"

alias neovide="flatpak run dev.neovide.neovide"
alias lg="lazygit"
alias ldr="lazydocker"
. "$HOME/.cargo/env"

# Backups
alias backup="systemctl --user start backup.service"
alias sdrl="systemctl --user daemon-reload"

alias spfy="spotify_player"
