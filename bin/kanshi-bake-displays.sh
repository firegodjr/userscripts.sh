#!/usr/bin/env bash
# kanshi-bake-displays.sh
# Reads current niri outputs and adds/updates a named profile in kanshi config
# Uses full monitor names (manufacturer model serial) instead of connector names

set -euo pipefail

KANSHI_CONFIG="$HOME/.config/kanshi/config"

if [[ $# -lt 1 ]]; then
    echo "Usage: kanshi-bake-displays.sh <profile-name>" >&2
    exit 1
fi

PROFILE_NAME="$1"

# Use distrobox-host-exec if niri isn't available directly
if command -v niri &>/dev/null; then
    NIRI_CMD="niri"
elif command -v distrobox-host-exec &>/dev/null; then
    NIRI_CMD="distrobox-host-exec niri"
else
    echo "Error: neither niri nor distrobox-host-exec found" >&2
    exit 1
fi

mkdir -p "$(dirname "$KANSHI_CONFIG")"
if [[ ! -f "$KANSHI_CONFIG" ]]; then
    touch "$KANSHI_CONFIG"
fi

outputs=$($NIRI_CMD msg outputs)

# Collect parsed outputs into parallel arrays
declare -a out_names=()
declare -a out_modes=()
declare -a out_scales=()
declare -a out_transforms=()
declare -a out_pos_x=()
declare -a out_pos_y=()

current_name=""
current_mode=""
current_scale=""
current_transform=""
current_px=""
current_py=""

flush_output() {
    if [[ -z "$current_name" ]]; then
        return
    fi

    # Map transform string to kanshi transform value
    local transform="normal"
    case "$current_transform" in
        *flipped-270*) transform="flipped-270" ;;
        *flipped-180*) transform="flipped-180" ;;
        *flipped-90*)  transform="flipped-90" ;;
        *flipped*)     transform="flipped" ;;
        *270*)         transform="270" ;;
        *180*)         transform="180" ;;
        *90*)          transform="90" ;;
        *)             transform="normal" ;;
    esac

    # Strip unnecessary trailing .0 from scale
    local scale
    scale=$(echo "$current_scale" | sed 's/\.0\+$//')
    [[ -z "$scale" ]] && scale="$current_scale"

    out_names+=("$current_name")
    out_modes+=("$current_mode")
    out_scales+=("$scale")
    out_transforms+=("$transform")
    out_pos_x+=("$current_px")
    out_pos_y+=("$current_py")
}

while IFS= read -r line; do
    if [[ "$line" =~ ^Output\ \"(.+)\"\ \((.+)\) ]]; then
        flush_output
        current_name="${BASH_REMATCH[1]}"
        current_mode=""
        current_scale=""
        current_transform=""
        current_px=""
        current_py=""
    elif [[ "$line" =~ Current\ mode:\ ([0-9]+x[0-9]+)\ @\ ([0-9.]+)\ Hz ]]; then
        current_mode="${BASH_REMATCH[1]}@${BASH_REMATCH[2]}Hz"
    elif [[ "$line" =~ Scale:\ ([0-9.]+) ]]; then
        current_scale="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ Transform:\ (.+) ]]; then
        current_transform="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ Logical\ position:\ (-?[0-9]+),\ (-?[0-9]+) ]]; then
        current_px="${BASH_REMATCH[1]}"
        current_py="${BASH_REMATCH[2]}"
    fi
done <<< "$outputs"
flush_output

if [[ ${#out_names[@]} -eq 0 ]]; then
    echo "No outputs detected."
    exit 0
fi

# Build the new profile block (no space before '{' for kanshi 1.6.0+)
profile_block="profile ${PROFILE_NAME} {"
for i in "${!out_names[@]}"; do
    name="${out_names[$i]}"
    mode="${out_modes[$i]}"
    scale="${out_scales[$i]}"
    transform="${out_transforms[$i]}"
    px="${out_pos_x[$i]}"
    py="${out_pos_y[$i]}"

    profile_block+=$'\n'"    output \"$name\" position $px,$py mode $mode scale $scale transform $transform"
done
profile_block+=$'\n'"}"

# Check if the profile already exists and replace it, or append
if grep -qP "^profile\s+\Q$PROFILE_NAME\E\s*\{" "$KANSHI_CONFIG"; then
    # Find the start and end lines of the existing profile block
    start_line=$(grep -nP "^profile\s+\Q$PROFILE_NAME\E\s*\{" "$KANSHI_CONFIG" | head -1 | cut -d: -f1)
    brace_offset=$(tail -n +"$start_line" "$KANSHI_CONFIG" | grep -n '^}' | head -1 | cut -d: -f1)
    end_line=$((start_line + brace_offset - 1))

    existing=$(sed -n "${start_line},${end_line}p" "$KANSHI_CONFIG")

    if [[ "$existing" == "$profile_block" ]]; then
        echo "Profile '$PROFILE_NAME' unchanged."
        exit 0
    fi

    echo "Updating profile '$PROFILE_NAME'."
    {
        head -n "$((start_line - 1))" "$KANSHI_CONFIG"
        printf '%s\n' "$profile_block"
        tail -n +"$((end_line + 1))" "$KANSHI_CONFIG"
    } > "${KANSHI_CONFIG}.tmp"
    mv "${KANSHI_CONFIG}.tmp" "$KANSHI_CONFIG"
else
    echo "Adding new profile '$PROFILE_NAME'."
    # Append to end of file, with a blank line separator if file is non-empty
    if [[ -s "$KANSHI_CONFIG" ]]; then
        printf '\n%s\n' "$profile_block" >> "$KANSHI_CONFIG"
    else
        printf '%s\n' "$profile_block" > "$KANSHI_CONFIG"
    fi
fi

echo "Kanshi config updated: $KANSHI_CONFIG"
