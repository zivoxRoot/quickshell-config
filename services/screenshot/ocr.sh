#!/usr/bin/env bash

notify-send --app-name="Tesseract" "OCR starting..."

RESULT=$(tesseract "$1" stdout)

action=$(notify-send \
  --app-name="Tesseract" \
  --action=copy="Copy" \
  "OCR completed (Tesseract)" "$RESULT")

case "$action" in
  "copy") wl-copy "$RESULT" ;;
esac
