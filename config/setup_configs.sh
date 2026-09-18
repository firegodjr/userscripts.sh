#!/usr/bin/env bash

set -euo pipefail

CONFIG_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG_HOME="$HOME/.config"
DRY_RUN=false

declare -A CONFIG_TARGETS=(
    # Entries are config-root subdirectories and their destination roots.
    [tmux]="$HOME"
)

usage() {
    printf 'Usage: %s [--dry-run]\n' "$(basename -- "${BASH_SOURCE[0]}")"
}

for arg in "$@"; do
    case "$arg" in
        --dry-run|-n)
            DRY_RUN=true
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

target_root_for() {
    local relative_path=$1
    local mapped_root relative_root

    for mapped_root in "${!CONFIG_TARGETS[@]}"; do
        if [[ "$relative_path" == "$mapped_root"/* || "$relative_path" == "$mapped_root" ]]; then
            printf '%s\n' "${CONFIG_TARGETS[$mapped_root]}"
            return
        fi
    done

    printf '%s\n' "$CONFIG_HOME"
}

while IFS= read -r -d '' source; do
    relative_path=${source#"$CONFIG_ROOT"/}
    target_root=$(target_root_for "$relative_path")

    for mapped_root in "${!CONFIG_TARGETS[@]}"; do
        if [[ "$relative_path" == "$mapped_root"/* ]]; then
            relative_path=${relative_path#"$mapped_root"/}
            break
        elif [[ "$relative_path" == "$mapped_root" ]]; then
            relative_path=$(basename -- "$relative_path")
            break
        fi
    done

    destination="$target_root/$relative_path"
    destination_dir=$(dirname -- "$destination")

    if [[ -L "$destination" && "$(readlink -- "$destination")" == "$source" ]]; then
        printf 'exists: %s -> %s\n' "$destination" "$source"
        continue
    fi

    if [[ -e "$destination" || -L "$destination" ]]; then
        printf 'skip (destination exists): %s\n' "$destination" >&2
        continue
    fi

    if [[ "$DRY_RUN" == true ]]; then
        printf 'mkdir -p %s\n' "$destination_dir"
        printf 'ln -s %s %s\n' "$source" "$destination"
        continue
    fi

    mkdir -p -- "$destination_dir"
    ln -s -- "$source" "$destination"
    printf 'linked: %s -> %s\n' "$destination" "$source"
done < <(find "$CONFIG_ROOT" -type f ! -path "$CONFIG_ROOT/$(basename -- "${BASH_SOURCE[0]}")" -print0)
