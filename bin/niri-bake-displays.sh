#!/usr/bin/env bash
# niri-bake-displays.sh
# Reads current niri outputs and adds/updates monitors in config.kdl

set -euo pipefail

CONFIG="$HOME/.config/niri/config.kdl"

# Use distrobox-host-exec if niri isn't available directly
if command -v niri &>/dev/null; then
    NIRI_CMD="niri"
elif command -v distrobox-host-exec &>/dev/null; then
    NIRI_CMD="distrobox-host-exec niri"
else
    echo "Error: neither niri nor distrobox-host-exec found" >&2
    exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
    echo "Error: config file not found at $CONFIG" >&2
    exit 1
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

    # Map transform string to niri config value
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
        current_mode="${BASH_REMATCH[1]}@${BASH_REMATCH[2]}"
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

changed=false
new_entries=""

for i in "${!out_names[@]}"; do
    name="${out_names[$i]}"
    mode="${out_modes[$i]}"
    scale="${out_scales[$i]}"
    transform="${out_transforms[$i]}"
    px="${out_pos_x[$i]}"
    py="${out_pos_y[$i]}"

    desired="output \"$name\" {
    mode \"$mode\"
    scale $scale
    transform \"$transform\"
    position x=$px y=$py
}"

    if grep -qF "\"$name\"" "$CONFIG"; then
        # Extract the existing block: find the line with the name, then grab until closing brace
        start_line=$(grep -n "\"$name\"" "$CONFIG" | head -1 | cut -d: -f1)
        brace_offset=$(tail -n +"$start_line" "$CONFIG" | grep -n '^}' | head -1 | cut -d: -f1)
        end_line=$((start_line + brace_offset - 1))

        existing=$(sed -n "${start_line},${end_line}p" "$CONFIG")

        if [[ "$existing" == "$desired" ]]; then
            echo "Unchanged: $name"
        else
            echo "Updated: $name"
            # Replace the block in-place
            {
                head -n "$((start_line - 1))" "$CONFIG"
                printf '%s\n' "$desired"
                tail -n +"$((end_line + 1))" "$CONFIG"
            } > "${CONFIG}.tmp"
            mv "${CONFIG}.tmp" "$CONFIG"
            changed=true
        fi
    else
        echo "New output: $name"
        new_entries+="$desired"$'\n\n'
        changed=true
    fi
done

# Append any new entries
if [[ -n "$new_entries" ]]; then
    last_output_line=$(grep -n '^output ' "$CONFIG" | tail -1 | cut -d: -f1 || true)

    if [[ -n "$last_output_line" ]]; then
        brace_offset=$(tail -n +"$last_output_line" "$CONFIG" | grep -n '^}' | head -1 | cut -d: -f1)
        insert_after=$((last_output_line + brace_offset - 1))
    else
        # No existing output blocks; insert before the layout section
        outputs_comment=$(grep -n 'Configuration:-Outputs' "$CONFIG" | head -1 | cut -d: -f1 || true)
        if [[ -n "$outputs_comment" ]]; then
            insert_after="$outputs_comment"
        else
            insert_after=$(grep -n '^layout {' "$CONFIG" | head -1 | cut -d: -f1)
            insert_after=$((insert_after - 1))
        fi
    fi

    {
        head -n "$insert_after" "$CONFIG"
        echo ""
        printf '%s' "$new_entries"
        tail -n +"$((insert_after + 1))" "$CONFIG"
    } > "${CONFIG}.tmp"
    mv "${CONFIG}.tmp" "$CONFIG"
fi

if [[ "$changed" == true ]]; then
    echo "Config updated: $CONFIG"
else
    echo "No changes needed."
fi
