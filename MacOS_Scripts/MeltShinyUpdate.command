#!/bin/bash

ZIP_URL="https://github.com/oss-slu/MeltWin2.0/archive/refs/heads/main.zip"

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROGRAM_DIR="$(dirname "$SCRIPT_DIR")"

# Create a temporary directory
mkdir -p "/tmp/UpdateTemp"
# Download the latest ZIP archive
curl -L -o "/tmp/UpdateTemp/latest.zip" "$ZIP_URL"
# Unzip the archive to the temporary location
unzip -o "/tmp/UpdateTemp/latest.zip" -d "/tmp/UpdateTemp"

# Delete all existing files and directories inside MeltWin2.0, excluding MacOS_Scripts and Windows_Scripts
find "$PROGRAM_DIR" -mindepth 1 -maxdepth 1 ! -name 'MacOS_Scripts' ! -name 'Windows_Scripts' -exec rm -rf {} \;
# Copy the contents of the unzipped folder to the program directory
cp -R "/tmp/UpdateTemp/MeltWin2.0-main/"* "$PROGRAM_DIR"

# Clean up the temporary directory
rm -r "/tmp/UpdateTemp"

echo "Update complete! Your program is now up to date."
exit 0

