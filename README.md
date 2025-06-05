# cliphist

A lightweight clipboard history manager for X11 using `xsel`, `dmenu`, and Bash.  
Store, access, and reuse your clipboard entries with ease.

## Features

- Copy primary selection or standard input to clipboard
- Automatically append to a persistent history file
- Select entries from clipboard history with `dmenu`
- Delete unwanted entries via interactive submenu
- Desktop notifications via `notify-send`
- History auto-trimmed to last 500 entries (configurable)

## Requirements

- `bash`
- `dwm`
- `dmenu`
- `xsel`
- `xdotool`
- `dunst`
- `notify-send` (usually from `libnotify-bin`)

Install on Alpine Linux

```bash
doas apk add xsel xdotool libnotify dunst
```

## Installation

Clone the repo and make the script executable:

```bash
git clone https://github.com/sebastianzehner/cliphist.git
cd cliphist
chmod +x dmenu_cliphist.sh
```

You may want to move it to a directory in your `$PATH`, e.g.:

```bash
cp dmenu_cliphist.sh ~/.local/bin/cliphist
```

## Usage

```bash
cliphist add     # Copy primary selection to clipboard and save to history
cliphist out     # Pipe stdin to clipboard and save to history
cliphist sel     # Launch clipboard history menu (via dmenu)
```

## Example Keybinding (with dwm)

You can bind a hotkey like `Alt + C` and `Alt + V` to copy or open the selection menu and paste in **config.def.h**:

```c
/* script launch bindings */
    { MODKEY,                        XK_v,      spawn,          {.v = (const char*[]){ "cliphist", "sel", NULL } } },
    { MODKEY,                        XK_c,      spawn,          {.v = (const char*[]){ "cliphist", "add", NULL } } },
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

This script uses the **PRIMARY selection** (text selected with the mouse or keyboard) as the main source for adding entries to the clipboard history.

However, some applications — especially browser-based editors like **Wiki.js in editing mode** — do **not provide a PRIMARY selection** at all. In such cases, the script detects this by checking whether the PRIMARY selection is empty or identical to the CLIPBOARD content. If so, it displays a **critical notification** indicating that copying isn't possible in the current context.

This prevents accidentally copying stale or irrelevant clipboard data.

To resolve this, simply exit the editing mode or switch to an application that supports primary selections.

## Acknowledgements

Built with 🧠 and 🖤 by [Sebastian](https://sebastianzehner.com)

Inspired by minimalism, speed, and [Bread](https://github.com/BreadOnPenguins/scripts/blob/master/dmenu_cliphist)
