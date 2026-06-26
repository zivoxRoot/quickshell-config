#!/usr/bin/env bash

matugen --mode dark --type scheme-fruit-salad --source-color-index 0 image "$1"
awww img --transition-type wave --transition-wave 50,50 "$1"
