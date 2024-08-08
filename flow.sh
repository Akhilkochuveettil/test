#!/bin/bash

# Function to check if ImageMagick is installed
check_imagemagick() {
    if command -v convert > /dev/null 2>&1; then
        echo "ImageMagick is already installed."
        return 0
    else
        echo "ImageMagick is not installed."
        return 1
    fi
}

# Function to install ImageMagick
install_imagemagick() {
    echo "Installing ImageMagick..."
    # Update package lists
    sudo apt-get update

    # Install ImageMagick
    sudo apt-get install -y imagemagick

    # Verify installation
    if command -v convert > /dev/null 2>&1; then
        echo "ImageMagick installation successful."
    else
        echo "ImageMagick installation failed."
        exit 1
    fi
}

# Check if ImageMagick is installed
if ! check_imagemagick; then
    # Install ImageMagick if not installed
    echo 'installing...'
    install_imagemagick
fi


# Directory to list files from
DIRECTORY="img"

# Check if a directory is provided as an argument
if [ "$1" ]; then
  DIRECTORY="$1"
fi

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
  echo "Directory $DIRECTORY does not exist."
  exit 1
fi

# List all files in the directory
echo "Files in directory $DIRECTORY:"
find "$DIRECTORY" -type f

# Optionally, you can also filter or sort the files
# For example, to list files sorted by name:
# find "$DIRECTORY" -type f | sort
ls "$DIRECTORY" | grep -v 'store.handler' | xargs -I@ convert img/@ -quality 50% photos/@

echo "Removing originals"

ls "$DIRECTORY" | grep -v 'store.handler' | xargs -I@ rm -f img/@

# Define the directory and files
PHOTO_DIR="photos"
HTML_FILE="index.html"
TEMP_FILE="temp.html"


# Create a temporary file to hold the updated content
cp "${HTML_FILE}.bak" "$TEMP_FILE"

# Generate image tags
IMAGES=""
for img in "$PHOTO_DIR"/*; do
    [ -f "$img" ] || continue
    img_name=$(basename "$img")
    IMAGES+="        <img src=\"$PHOTO_DIR/$img_name\" alt=\"$img_name\">\n"
done

# Replace %%IMAGES%% with the generated image tags
sed -i "/%%IMAGES%%/r /dev/stdin" "$TEMP_FILE" <<< "$IMAGES"
cp "$TEMP_FILE" "$HTML_FILE".bak

sed -i "s/%%IMAGES%%//g" "$TEMP_FILE"

# Replace the original HTML file with the updated one
mv "$TEMP_FILE" "$HTML_FILE"
