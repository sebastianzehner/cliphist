#!/usr/bin/env bash

# Path to the clipboard history file
histfile="$HOME/.cache/cliphist"

# Placeholder used to represent newlines in stored entries
placeholder="<NEWLINE>"

# Copies the primary X11 selection to the clipboard
highlight() {
  # Read current PRIMARY and CLIPBOARD contents
  primary=$(xsel -o -p 2>/dev/null)
  clipboard=$(xsel -o -b 2>/dev/null)

  # If PRIMARY is empty or hasn't changed, assume the app doesn't provide it
  if [[ -z "$primary" || "$primary" == "$clipboard" ]]; then
    app_name=$(xdotool getwindowfocus getwindowname)
    notify-send -u critical " Copy failed" \
      "The application \"$app_name\" does not provide PRIMARY selection."
    return
  fi

  # Update clipboard with PRIMARY content
  echo "$primary" | xsel -i -b
  clip="$primary"
}

# Reads stdin and stores it to the clipboard
output() {
  clip=$(cat)
  echo "$clip" | xsel -i -b
}

# Saves the clipboard content to the history file, avoiding duplicates
write() {
  # Create history file if it doesn't exist
  if [ ! -f "$histfile" ]; then
    notify-send " Creating... $histfile"
    touch "$histfile"
  fi

  # Exit if clipboard content is empty
  [ -z "$clip" ] && exit 0

  # Replace newlines with placeholder for single-line storage
  multiline=$(echo "$clip" | sed ':a;N;$!ba;s/\n/'"$placeholder"'/g')

  # Only add to history if not already present
  if ! grep -Fxq "$multiline" "$histfile"; then
    echo "$multiline" >> "$histfile"
  fi

  # Limit history to the last 500 entries
  tail -n 500 "$histfile" > "$histfile.tmp" && mv "$histfile.tmp" "$histfile"

  # Prepare a notification based on clip length
  if (( ${#clip} > 100 )); then
    notification=("󰢨 Saved to clipboard history" "${clip:0:100}...")
  else
    notification=("󰢨 Saved to clipboard history" "$clip")
  fi
}

# Shows clipboard history via dmenu, allows inserting or deleting entries
sel() {
  menu_header="--- menu ---"
  delete_entry="󰆴 delete entry"

  # Combine history with menu options and present via dmenu
  selection=$( (tac "$histfile"; echo "$menu_header"; echo "$delete_entry") | dmenu -b -l 10 -i -p "Clipboard history:" -nb "#11111b" -nf "#b4befe" -sb "#89b4fa" -sf "#11111b")

  # Exit if user presses ESC or selects menu header
  if [[ -z "$selection" || "$selection" == "$menu_header" ]]; then
    return
  fi

  # If the delete entry is selected, open deletion submenu
  if [[ "$selection" == "$delete_entry" ]]; then
    to_delete=$(tac "$histfile" | dmenu -b -l 10 -i -p "Select entry to delete:" -nb "#11111b" -nf "#b4befe" -sb "#89b4fa" -sf "#11111b")
    if [[ -z "$to_delete" ]]; then
      return # Exit if ESC is pressed in delete menu
    fi
    # Remove selected entry safely
    awk -v target="$to_delete" '$0 != target' "$histfile" > "$histfile.tmp" && mv "$histfile.tmp" "$histfile"
    notification="Deleted from clipboard history!"
    return
  fi

  # Restore selected entry (convert placeholder back to newlines) and paste
  printf "$selection" | sed "s/$placeholder/\n/g" | xsel -i -b
  xdotool key --clearmodifiers ctrl+shift+v
  notification="Inserted from clipboard!"
}

# Entry point: handle subcommands
case "$1" in
  add) highlight && write ;;  # Copy primary selection and save to history
  out) output && write ;;     # Read from stdin and save to history
  sel) sel ;;                 # Show clipboard history menu
  *) # Show help message
    printf "$0 | History file: $histfile\n\n"
    printf "add - copies primary selection to clipboard, and adds to history file\n"
    printf "out - pipe commands to copy output to clipboard, and add to history file\n"
    printf "sel - select from history file with dmenu and recopy!\n"
    exit 0
    ;;
esac

# Show notification if one was set
[ -z "${notification[*]}" ] || notify-send -u low "${notification[@]}"
