#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROGRAM_DIR="$(dirname "$SCRIPT_DIR")"

# Get the name of the program directory
PROGRAM_NAME="$(basename "$PROGRAM_DIR")"

# Check if the program directory is named 'MeltShiny-main'
# -main signifies this was locally installed by a user from the repository.
if [ "$PROGRAM_NAME" != "MeltShiny-main" ]; then
    echo "Error: The parent directory is not 'MeltShiny-main'! Exiting..."
    exit 1
fi

ZIP_URL="https://github.com/oss-slu/MeltWin2.0/archive/refs/heads/main.zip"
CODE_DIR="$PROGRAM_DIR/code" # specify the Code subdirectory

# Create a temporary directory
mkdir -p "/tmp/UpdateTemp"
# Download the latest ZIP archive
curl -L -o "/tmp/UpdateTemp/latest.zip" "$ZIP_URL"
# Unzip the archive to the temporary location
unzip -o "/tmp/UpdateTemp/latest.zip" -d "/tmp/UpdateTemp"

# Delete only the 'code' subdirectory inside PROGRAM_DIR
rm -rf "$CODE_DIR"
# Copy the 'code' subdirectory from the unzipped folder to PROGRAM_DIR
cp -R "/tmp/UpdateTemp/MeltWin2.0-main/code" "$PROGRAM_DIR"

# Clean up the temporary directory
rm -r "/tmp/UpdateTemp"

echo "Update complete! Your program's 'code' subdirectory is now up to date."
exit 0
