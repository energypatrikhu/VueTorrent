#!/bin/bash

echo "Checking for updates..."

get_latest_vuetorrent_version() {
  curl -s "https://api.github.com/repos/VueTorrent/VueTorrent/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/'
}
get_latest_qbittorrent_version() {
  curl -s "https://hub.docker.com/v2/repositories/qbittorrentofficial/qbittorrent-nox/tags?page_size=100&ordering=last_updated" \
    | jq -r '.results[].name' \
    | grep -Ev 'latest|alpha|beta|rc' \
    | head -n1
}

get_current_version() {
  if [ -f .docker-publish ]; then
    grep '"version":' .docker-publish | sed -E 's/.*"([^"]+)".*/\1/'
  else
    echo "0.0.0_0.0.0"
  fi
}
get_image_name() {
  if [ -f .docker-publish ]; then
    grep '"dockerImageName":' .docker-publish | sed -E 's/.*"([^"]+)".*/\1/'
  else
    echo "ghcr.io/energypatrikhu/vuetorrent"
  fi
}

IMAGE_NAME=$(get_image_name)
CURRENT_VERSION=$(get_current_version)
CURRENT_QBIT_VERSION=$(echo $CURRENT_VERSION | cut -d'_' -f1)
CURRENT_VUE_VERSION=$(echo $CURRENT_VERSION | cut -d'_' -f2)
LATEST_VUETORRENT_VERSION=$(get_latest_vuetorrent_version)
LATEST_QBIT_VERSION=$(get_latest_qbittorrent_version)
LATEST_VERSION="$LATEST_QBIT_VERSION"_"$LATEST_VUETORRENT_VERSION"

echo "[VueTorrent] Current version: $CURRENT_VUE_VERSION"
echo "[VueTorrent] Latest version: $LATEST_VUETORRENT_VERSION"
echo "[qBittorrent] Current version: $CURRENT_QBIT_VERSION"
echo "[qBittorrent] Latest version: $LATEST_QBIT_VERSION"

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "New version available. Updating .docker-publish file."

  # Update .docker-publish file
  cat > .docker-publish <<EOL
{
  "dockerImageName": "$IMAGE_NAME",
  "version": "$LATEST_VERSION"
}
EOL
  echo ".docker-publish file updated to version $LATEST_VERSION"

  # Build and push Docker image
  echo "Building and pushing Docker image $IMAGE_NAME:$LATEST_VERSION"
  docker build --no-cache -t $IMAGE_NAME:$LATEST_VERSION -t $IMAGE_NAME:latest .
  docker push $IMAGE_NAME:$LATEST_VERSION
  docker push $IMAGE_NAME:latest
  echo "Docker image $IMAGE_NAME:$LATEST_VERSION built and pushed."

  # Commit and push changes to GitHub
  echo "Committing and pushing changes to GitHub."
  git add .docker-publish
  git commit -m "Update to version $LATEST_VERSION"
  git push origin main
  echo "Changes pushed to GitHub."
else
  echo "No new version available. Current version is up-to-date."
fi
