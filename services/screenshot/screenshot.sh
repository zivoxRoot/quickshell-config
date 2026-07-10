#!/usr/bin/env bash

OUTPUT_DIR="$HOME/Pictures/Screenshots"
FILENAME="$(date +'%Y-%m-%d_%H-%M-%S').png"
FILEPATH="$OUTPUT_DIR/$FILENAME"

mkdir -p "$OUTPUT_DIR"

notify() {
  local action
  action=$(notify-send \
    --app-name="Screenshot" \
    --action=copy="Copy path" \
    --action=edit="Edit" \
    --action=delete="Delete" \
    --action=find="Search" \
    --action=ocr="OCR" \
    --icon="$FILEPATH" \
    "Screenshot taken & copied to clipboard" "$FILEPATH")

  case "$action" in
    "copy") wl-copy "$FILEPATH" ;;
    "edit")
      satty --filename "$FILEPATH" &
      disown
      notify-send "Screenshot copied"
      ;;
    "delete")
      rm "$FILEPATH" &
      disown
      notify-send "Screenshot deleted"
      ;;
    "find")
      "$HOME/.config/quickshell/services/screenshot/google_search.sh" "$FILEPATH" &
      disown
      ;;
    "ocr")
      "$HOME/.config/quickshell/services/screenshot/ocr.sh" "$FILEPATH" &
      disown
      ;;
  esac
}

FREEZE_ARGS=()
if [[ "$2" == "freeze" ]]; then
  FREEZE_ARGS+=(--freeze)
fi

case "$1" in
  "fullscreen")
    hyprshot "${FREEZE_ARGS[@]}" --silent --output-folder "$OUTPUT_DIR" --filename "$FILENAME" --mode output
    ;;
  "window")
    hyprshot "${FREEZE_ARGS[@]}" --silent --output-folder "$OUTPUT_DIR" --filename "$FILENAME" --mode window
    ;;
  "region")
    hyprshot "${FREEZE_ARGS[@]}" --silent --output-folder "$OUTPUT_DIR" --filename "$FILENAME" --mode region
    ;;
esac

notify
