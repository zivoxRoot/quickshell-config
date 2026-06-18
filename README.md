# Quickshell config

My `quickshell` config (just starting with it). The goal is to have a working shell to replace common utilities on wayland compositors such as `waybar`, `rofi`, `swaync`...

## Usage

1. Install `quickshell`
2. Clone this repo at **~/.config/quickshell**
3. Use `qs` with no arguments to automatically launch the shell

## Structure

**shell.qml** - the main entry point, it just calls the different modules
**modules/** - big modules (bar, notification center, lock screen...) and their UI files
**services/** - reusable services related to OS interactions, used by modules
**config/** - the Config singleton, fetching settings and colors dynamically

## TODOs

- [ ] Dynamic settings and colors from config file and `matugen`-generated color file in Config singleton
