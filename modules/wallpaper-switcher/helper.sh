#!/usr/bin/env bash

# Wallpapers Path
wallpapersDir="$HOME/Pictures/Wallpapers"
iconsDir="$HOME/.cache/wallpaper-select"

# Additional config
THEME_FILE="$HOME/.cache/current-theme/theme.txt"
DEFAULT_THEME="dark"
CURRENT_THEME=""

# getPics retrieves image files as a list, restricted to top-level directory
getPics() {
    # Find files, prioritizing JPG/JPEG over PNG/GIF
    PICS=($(find -L "${wallpapersDir}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | sort))
    # Deduplicate based on base name, preferring JPG/JPEG
    declare -A seen
    declare -A file_map
    for pic in "${PICS[@]}"; do
        base_name=$(basename "$pic" | cut -d. -f1)
        ext=$(echo "${pic##*.}" | tr '[:upper:]' '[:lower:]')
        # Prioritize JPG/JPEG over PNG/GIF
        if [[ -z "${seen[$base_name]}" || "$ext" == "jpg" || "$ext" == "jpeg" ]]; then
            seen[$base_name]=1
            file_map[$base_name]="$pic"
        fi
    done
    unique_pics=()
    for base_name in "${!file_map[@]}"; do
        unique_pics+=("${file_map[$base_name]}")
    done
    # Sort to maintain consistent order
    IFS=$'\n' unique_pics=($(sort <<<"${unique_pics[*]}"))
    unset IFS
    PICS=("${unique_pics[@]}")
}

# updateIconFolder checks that all wallpapers in $wallpapersDir have a corresponding icon in $iconsDir
updateIconFolder() {
    # Create a map of wallpapers by base name, prioritizing JPG/JPEG
    declare -A wallpaper_map
    for file in "$wallpapersDir"/*.{jpg,jpeg,png,gif}; do
        [[ -e "$file" ]] || continue # Skip if no files are found
        base_name=$(basename "$file" | cut -d. -f1)
        ext=$(echo "${file##*.}" | tr '[:upper:]' '[:lower:]')
        # Store file, preferring JPG/JPEG
        if [[ -z "${wallpaper_map[$base_name]}" || "$ext" == "jpg" || "$ext" == "jpeg" ]]; then
            wallpaper_map[$base_name]="$file"
        fi
    done

    # Generate icons for each unique wallpaper
    for base_name in "${!wallpaper_map[@]}"; do
        file="${wallpaper_map[$base_name]}"
        ext=$(echo "${file##*.}" | tr '[:upper:]' '[:lower:]')
        # Check if the icon exists in $iconsDir (icons are always JPG)
        if [[ ! -e "$iconsDir/$base_name.jpg" ]]; then
            notify-send "Wallpaper switcher" "Converting $base_name to icon"
            # Convert to JPG icon (use first frame for GIF)
            if [[ "$ext" == "gif" ]]; then
                magick "$file[0]" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "$iconsDir/$base_name.jpg"
            else
                # magick "$file" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "$iconsDir/$base_name.jpg"
                magick "$file" -strip -thumbnail 500x500^ -gravity center "$iconsDir/$base_name.jpg"
            fi
        fi
    done

    # Remove icons without a corresponding wallpaper
    for file in "$iconsDir"/*.jpg; do
        [[ -e "$file" ]] || continue # Skip if no icons are found
        base_name=$(basename "$file" .jpg)
        if [[ -z "${wallpaper_map[$base_name]}" ]]; then
            notify-send "Wallpaper switcher" "Deleting icon $base_name.jpg"
            rm "$iconsDir/$base_name.jpg"
        fi
    done

    # Reload the wallpapers list
    getPics
}

# Check that the dependencies exist and call the necessary functions
main() {
    # Ensure ImageMagick is installed
    if ! command -v magick &>/dev/null; then
        notify-send "Wallpaper switcher" "ImageMagick is not installed"
        exit 1
    fi

    # Ensure both folders exist
    if [[ ! -d "$wallpapersDir" || ! -d "$iconsDir" ]]; then
        notify-send "Wallpaper switcher" "One or both folders don't exist..."
        exit 1
    fi

    getPics

    updateIconFolder
}

# Ensure the theme file exists
[ ! -f "$THEME_FILE" ] && echo "$DEFAULT_THEME" > "$THEME_FILE"
# Read the current theme
CURRENT_THEME=$(cat "$THEME_FILE")

# Check the necessary folders exist, and create them if they do not
if [ ! -d "$wallpapersDir" ]; then
    mkdir -p "$wallpapersDir"
    echo "Created folder: $wallpapersDir" >> ~/.wallpaper-select.log
else
    echo "Folder already exists: $wallpapersDir" >> ~/.wallpaper-select.log
fi
if [ ! -d "$iconsDir" ]; then
    mkdir -p "$iconsDir"
    echo "Created folder: $iconsDir" >> ~/.wallpaper-select.log
else
    echo "Folder already exists: $iconsDir" >> ~/.wallpaper-select.log
fi

# Call the main function
main
