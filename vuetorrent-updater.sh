#!/bin/sh

# Define variables
AUTHOR="VueTorrent"
REPO="VueTorrent"
REPO_PATH="$AUTHOR/$REPO"
DOWNLOAD_URL="https://github.com/$REPO_PATH/releases/latest/download/vuetorrent.zip"
ZIP_FILE="/vuetorrent.zip"
VUETORRENT_DIR="/vuetorrent"
VERSION_FILE="$VUETORRENT_DIR/version.txt"

# Function to get the latest release version from GitHub API
get_latest_version() {
  curl -s "https://api.github.com/repos/$REPO_PATH/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/'
}

# Check if the VueTorrent folder exists
if [ ! -d "$VUETORRENT_DIR" ]; then
  echo "[$REPO] VueTorrent folder not found. Downloading the latest version..."

  # Download the latest VueTorrent zip file
  curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL"

  # Extract the zip file into the root directory
  unzip -o "$ZIP_FILE" -d /

  # Remove the zip file after extraction
  rm "$ZIP_FILE"

  echo "[$REPO] Download complete."

  exit 0
fi

# Check if version file exists inside the VueTorrent folder
if [ ! -f "$VERSION_FILE" ]; then
  echo "0" >"$VERSION_FILE"
fi

# Read the current version from the version file
CURRENT_VERSION=$(cat "$VERSION_FILE")

# Get the latest version from GitHub
LATEST_VERSION=$(get_latest_version)

# Compare versions
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "[$REPO] New version available: $LATEST_VERSION. Downloading..."

  # Download the latest VueTorrent zip file
  curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL"

  # Extract the zip file into the root directory
  unzip -o "$ZIP_FILE" -d /

  # Remove the zip file after extraction
  rm "$ZIP_FILE"

  # Update the version file with the latest version
  echo "$LATEST_VERSION" >"$VERSION_FILE"

  echo "[$REPO] Download complete. Version updated to $LATEST_VERSION."
else
  echo "[$REPO] Already on the latest version: $CURRENT_VERSION."
fi
