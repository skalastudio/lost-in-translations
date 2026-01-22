#!/usr/bin/env bash
set -euo pipefail

bundle_id="com.lostintranslations.app"
remove_container=false
force_remove=false
show_help=false
has_args=false

while [[ $# -gt 0 ]]; do
    has_args=true
    case "$1" in
        --bundle-id)
            if [[ -n "${2:-}" ]]; then
                bundle_id="$2"
                shift 2
                continue
            fi
            echo "Missing value for --bundle-id."
            exit 1
            ;;
        --full-reset)
            remove_container=true
            shift
            ;;
        --force)
            force_remove=true
            shift
            ;;
        -h|--help)
            show_help=true
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--bundle-id <id>] [--full-reset] [--force]"
            exit 1
            ;;
    esac
done

if [[ "${has_args}" == false ]]; then
    echo "Tip: run with --help to see all options."
fi

if [[ "${show_help}" == true ]]; then
    cat <<'EOF'
Usage: user-defaults-reset.sh [--bundle-id <id>] [--full-reset] [--force]

Options:
  --bundle-id <id>  Override the default bundle identifier.
  --full-reset      Remove the sandbox container for a true first-run reset.
  --force           Skip the confirmation prompt for --full-reset.
  -h, --help         Show this help message.
EOF
    exit 0
fi

echo "Clearing UserDefaults for ${bundle_id}..."

defaults delete "${bundle_id}" >/dev/null 2>&1 || true

prefs_file="${HOME}/Library/Preferences/${bundle_id}.plist"
sandbox_prefs_file="${HOME}/Library/Containers/${bundle_id}/Data/Library/Preferences/${bundle_id}.plist"
container_root="${HOME}/Library/Containers/${bundle_id}"

rm -f "${prefs_file}" "${sandbox_prefs_file}"

if [[ "${remove_container}" == true ]]; then
    if [[ "${force_remove}" == true ]]; then
        rm -rf "${container_root}"
    else
        read -r -p "This will remove ${container_root}. Continue? [y/N] " confirm
        if [[ "${confirm}" == "y" || "${confirm}" == "Y" ]]; then
            rm -rf "${container_root}"
        else
            echo "Skipping container removal."
        fi
    fi
fi

echo "Done. Relaunch the app to start with fresh defaults."
