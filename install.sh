#!/bin/bash
# RotLock installer / updater.
#   curl -fsSL https://raw.githubusercontent.com/Samuel-Gaston-Clarke/rotlock-releases/main/install.sh | bash
# Downloads the latest RotLock.app, checks it, puts it in /Applications and opens it.
# Never asks for your password: the app does that once, when you click "Install helper".
# Everything runs inside main(), so a half-downloaded script does nothing.
set -euo pipefail

main() {
    local base="${ROTLOCK_BASE_URL:-https://github.com/Samuel-Gaston-Clarke/rotlock-releases/releases/latest/download}"
    local apps="${ROTLOCK_APPS_DIR:-/Applications}"
    local os="${ROTLOCK_OS_VERSION:-$(sw_vers -productVersion)}"

    say "RotLock installer"

    if (( ${os%%.*} < 14 )); then
        die "RotLock needs macOS 14 (Sonoma) or newer. This Mac has macOS $os."
    fi
    [[ -w "$apps" ]] || die "Can't write to $apps. Use an admin account."

    tmp=$(mktemp -d)  # global: the EXIT trap runs after main returns
    trap 'rm -rf "$tmp"' EXIT

    say "Downloading..."
    curl -fsSL "$base/RotLock.zip" -o "$tmp/RotLock.zip" </dev/null \
        || die "Download failed. Check your internet connection and try again."
    curl -fsSL "$base/RotLock.zip.sha256" -o "$tmp/RotLock.zip.sha256" </dev/null \
        || die "Download failed. Check your internet connection and try again."

    say "Checking download..."
    (cd "$tmp" && shasum -a 256 -c RotLock.zip.sha256 >/dev/null 2>&1) \
        || die "The download is damaged (checksum mismatch). Nothing was changed. Try again."

    ditto -x -k "$tmp/RotLock.zip" "$tmp/unzipped"
    [[ -d "$tmp/unzipped/RotLock.app" ]] || die "The download doesn't contain RotLock.app. Nothing was changed."

    # Quit the app if it's open (any running block keeps going: the helper runs it).
    if pgrep -x RotLock >/dev/null; then
        say "Closing RotLock to update it..."
        pkill -x RotLock || true
        for _ in $(seq 1 20); do pgrep -x RotLock >/dev/null || break; sleep 0.25; done
    fi

    # Copy the new app in next to the old one first, then swap, so a failure
    # never leaves you without RotLock.
    local new="$apps/.RotLock.app.new" old="$apps/.RotLock.app.old"
    rm -rf "$new" "$old" 2>/dev/null || true
    if ! ditto "$tmp/unzipped/RotLock.app" "$new" 2>/dev/null; then
        rm -rf "$new" 2>/dev/null || true
        die "Couldn't copy RotLock into $apps (is the disk full?). Nothing was changed."
    fi
    if [[ -e "$apps/RotLock.app" ]] && ! mv "$apps/RotLock.app" "$old" 2>/dev/null; then
        rm -rf "$new" 2>/dev/null || true
        die "macOS blocked Terminal from replacing RotLock. Open System Settings > Privacy & Security > App Management, turn on Terminal, then run the command again. Your current RotLock is unchanged."
    fi
    mv "$new" "$apps/RotLock.app"
    rm -rf "$old" 2>/dev/null || true
    xattr -dr com.apple.quarantine "$apps/RotLock.app" 2>/dev/null || true

    if [[ -z "${ROTLOCK_NO_OPEN:-}" ]]; then
        open "$apps/RotLock.app"
    fi

    cat <<'EOF'

RotLock is installed and open.

Next:
  1. First time only: click "Install helper" in RotLock and enter your Mac password.
     macOS will say a background item was added: that's the helper, leave it on.
  2. Chrome block page (optional, once per Chrome profile):
     RotLock > Settings (Cmd+,) > Chrome > "Set up in Chrome...", then follow the steps.

Update later: run the same command again. A running block keeps going.
If RotLock then shows "Update helper", click it and enter your password.
Uninstall:    sudo "/Library/Application Support/RotLock/uninstall.sh"
EOF
}

say() { printf '%s\n' "$*"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

main "$@"
