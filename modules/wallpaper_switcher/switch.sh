#!/usr/bin/env bash

# Switch wallpaper and generate colors
matugen --mode dark --type scheme-fruit-salad --source-color-index 0 image "$1"
awww img --transition-type wave --transition-wave 50,50 "$1"

# Cache the wallpaper for the lockscreen to use
mkdir -p $HOME/.cache/current_wallpaper/
cp $1 $HOME/.cache/current_wallpaper/current.jpg
