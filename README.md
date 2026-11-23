# RotLock

Website blocker for macOS against brain rot. Once a block starts you can't just switch it off. To end it early you have to type out random text and then wait out a countdown.

Needs macOS 14 (Sonoma) or newer. Built for Apple Silicon and Intel Macs (tested on Apple Silicon).

## Install

Open Terminal, paste this, press Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/Samuel-Gaston-Clarke/rotlock-releases/main/install.sh | bash
```

RotLock opens. Click **Install helper** and enter your Mac password (once). That's the part that does the blocking. macOS will say a background item was added: that's the helper, leave it switched on.

Don't download the zip from the Releases page in a browser: macOS won't open it. Use the command.

## Use

- Add sites, pick a length, start a block. It survives quitting the app and restarting the Mac.
- **Settings (⌘,)**: weekly schedule, block page text, unlock difficulty.
- Ending a block early: type the random text shown (no pasting), then wait the countdown.

## Chrome block page (optional)

Blocking works in every browser without this. In Chrome it adds a proper "blocked" page instead of an error.

1. RotLock → Settings → Chrome → **Set up in Chrome…** (opens a folder).
2. In Chrome go to `chrome://extensions` and turn on **Developer mode** (top right).
3. Drag the folder onto that page. Do this once per Chrome profile.

## Update

Run the install command again. A running block keeps going. If RotLock then shows **Update helper**, click it and enter your password.

If Terminal says macOS blocked it from replacing RotLock: System Settings → Privacy & Security → App Management → turn on Terminal, then run the command again.

## Uninstall

```bash
sudo "/Library/Application Support/RotLock/uninstall.sh"          # refuses while a block runs
sudo "/Library/Application Support/RotLock/uninstall.sh" --force  # emergency exit: ends a block too
```

Then drag RotLock from Applications to the Bin, and remove it at `chrome://extensions` if you added it. Never clicked Install helper? Just delete the app.

## Limits

- An admin can always get round it (`sudo`). It adds friction, not security.
- A VPN or a browser with its own DNS setting can get round it.
