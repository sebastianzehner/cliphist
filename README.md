# cliphist

A lightweight clipboard history manager for X11 and Wayland, written in Bash.  
It uses `xsel` or `wl-clipboard` for the clipboard and `qmenu` (a `dmenu`-compatible menu) for the selection.  
Store, access, and reuse your clipboard entries with ease.

## Features

- Copy primary selection or standard input to clipboard
- Automatically append to a persistent history file
- Works on X11 (`dwm`) and Wayland (Hyprland), chosen automatically via `$WAYLAND_DISPLAY`
- Select entries from clipboard history with `qmenu` (`dmenu` on X11, Quickshell on Wayland)
- Delete unwanted entries via interactive submenu
- Desktop notifications via `notify-send`
- History auto-trimmed to last 500 entries (configurable)

## Requirements

Both sessions:

- `bash`
- `qmenu` (a `dmenu`-compatible wrapper, see below)
- `dunst`
- `notify-send` (usually from `libnotify-bin`)

X11 (`dwm`):

- `dwm`
- `dmenu`
- `xsel`
- `xdotool`

Wayland (Hyprland):

- `Hyprland` (for `hyprctl`)
- `quickshell` with the `Menu.qml` menu loaded
- `wl-clipboard` (`wl-paste`, `wl-copy`)
- `wtype`
- `jq`

The script always calls `qmenu`.
On X11 it simply runs `dmenu` with the same arguments, on Wayland it opens the menu in Quickshell.

Install on Alpine Linux (X11)

```bash
doas apk add xsel xdotool libnotify dunst
```

Install on Arch Linux (X11)

```bash
sudo pacman -Syu xsel xdotool libnotify dunst
```

Install on Arch Linux (Wayland)

```bash
sudo pacman -Syu wl-clipboard wtype jq libnotify dunst quickshell
```

## Installation

Clone the repo and make the script executable:

```bash
git clone https://github.com/sebastianzehner/cliphist.git
cd cliphist
chmod +x cliphist.sh
```

You may want to move it to a directory in your `$PATH`, e.g.:

```bash
cp cliphist.sh /usr/local/bin/cliphist
```

## Usage

```bash
cliphist add     # Copy primary selection to clipboard and save to history
cliphist out     # Pipe stdin to clipboard and save to history
cliphist sel     # Launch clipboard history menu (via qmenu)
```

## Example Keybinding (with dwm)

You can bind a hotkey like `Alt + C` and `Alt + V` to copy or open the selection menu and paste in **config.def.h**:

```c
/* script launch bindings */
    { MODKEY,                        XK_v,      spawn,          {.v = (const char*[]){ "cliphist", "sel", NULL } } },
    { MODKEY,                        XK_c,      spawn,          {.v = (const char*[]){ "cliphist", "add", NULL } } },
```

## Example Keybinding (with Hyprland)

The same hotkeys in **hyprland.conf**:

```ini
bind = ALT, V, exec, cliphist sel
bind = ALT, C, exec, cliphist add
```

## History File

By default, clipboard entries are saved to:

```bash
~/.cache/cliphist
```

Multiline entries are stored as single lines with a `<NEWLINE>` placeholder and restored when selected.

## Configuration

You can adjust the maximum number of stored entries by modifying this line in the script:

```bash
tail -n 500 "$histfile" > "$histfile.tmp" && mv "$histfile.tmp" "$histfile"
```

## Clipboard Selection Handling

This script uses the **PRIMARY selection** (text selected with the mouse or keyboard) as the main source for adding
entries to the clipboard history.

However, some applications — especially browser-based editors like **Wiki.js in editing mode** — do **not provide a
PRIMARY selection** at all. In such cases, the script detects this by checking whether the PRIMARY selection is empty or
identical to the CLIPBOARD content.
If so, it displays a **critical notification** indicating that copying isn't possible in the current context.

This prevents accidentally copying stale or irrelevant clipboard data.

To resolve this, simply exit the editing mode or switch to an application that supports primary selections.

On Wayland the PRIMARY selection is read with `wl-paste --primary`, so the compositor and the application must support
the primary selection protocol.

## Acknowledgements

Built with 🧠 and 🖤 by [Sebastian](https://sebastianzehner.com)

Inspired by minimalism, speed, and [Bread](https://github.com/BreadOnPenguins/scripts/blob/master/dmenu_cliphist)
