#!/usr/bin/env bash

OUTPUT_DIR="$HOME/Pictures/Screenshots"
FILENAME="$(date +'%Y-%m-%d_%H-%M-%S').mkv"
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
    "open") satty --filename "$FILEPATH" ;;
    "delete") rm "$FILEPATH" ;;
    "find") notify-send "FIND THIS SHIT" "$FILEPATH" ;;
    "ocr") notify-send "OCR THIS SHIT" "$FILEPATH" ;;
  esac
}

FREEZE_ARGS=()
if [[ "$2" == "freeze" ]]; then
  FREEZE_ARGS+=(--freeze)
fi

case "$1" in
  "fullscreen")
    hyprshot "${FREEZE_ARGS[@]}" --silent --output-folder "$FILEPATH" --mode output
    notify
    ;;
  "window")
    hyprshot "${FREEZE_ARGS[@]}" --silent --output-folder "$FILEPATH" --mode window
    notify
    ;;
  "region")
    hyprshot "${FREEZE_ARGS[@]}" --silent --output-folder "$FILEPATH" --mode region
    notify
    ;;
esac
