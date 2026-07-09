#!/usr/bin/env bash

OUTPUT_DIR="$HOME/Pictures/Recordings"
FILENAME="$(date +'%Y-%m-%d_%H-%M-%S').mkv"
FILEPATH="$OUTPUT_DIR/$FILENAME"

mkdir -p "$OUTPUT_DIR"

get_window_geometry() {
  local monitors=`hyprctl -j monitors`
  local clients=`hyprctl -j clients | jq -r '[.[] | select(.workspace.id | contains('$(echo $monitors | jq -r 'map(.activeWorkspace.id) | join(",")')'))]'`
  local boxes="$(echo $clients | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1]) \(.title)"' | cut -f1,2 -d' ')"
  local geometry=$(slurp -r <<< "$boxes")
  echo "$geometry"
}

get_region_geometry() {
  local geometry=$(slurp)
  echo "$geometry"
}

start_notify() {
  notify-send --app-name="Screenrecord" "Recording started"
  # local action  # NOTE: doesn't work as it doesn't stop the `recording` state in the QML app...
  # action=$(notify-send \
  #   --app-name="Screenshot" \
  #   --action=stop="Stop" \
  #   "Recording started")

  # case "$action" in
  #   "stop")
  #     pkill -x wf-recorder
  #     stop_notify
  #     ;;
  # esac
}

stop_notify() {
  local action
  action=$(notify-send \
    --app-name="Screenrecord" \
    --action=copy="Copy path" \
    --action=open="Open" \
    --action=delete="Delete" \
    "Recording ended" "$FILEPATH")

  case "$action" in
    "copy") wl-copy "$FILEPATH" ;;
    "open") mpv "$FILEPATH" ;;
    "delete") rm "$FILEPATH" ;;
  esac
}

case "$1" in
  "fullscreen")
    start_notify
    wf-recorder -f "$FILEPATH" --output "$2"
    ;;
  "window")
    WINDOW_GEOMETRY=$(get_window_geometry)
    start_notify
    wf-recorder -f "$FILEPATH" --geometry "$WINDOW_GEOMETRY"
    ;;
  "region")
    REGION_GEOMETRY=$(get_region_geometry)
    start_notify
    wf-recorder -f "$FILEPATH" --geometry "$REGION_GEOMETRY"
    ;;
  "stop")
    pkill -x wf-recorder
    stop_notify
    ;;
esac
