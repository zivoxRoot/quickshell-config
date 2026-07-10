#!/usr/bin/env bash

cp "$1" /tmp/image.png
imageLink=$(curl -sF files[]=@/tmp/image.png 'https://uguu.se/upload' | jq -r '.files[0].url')
echo "$imageLink"
xdg-open "https://lens.google.com/uploadbyurl?url=${imageLink}"
rm /tmp/image.png

notify-send "Google search finished" "Go to your browser"
