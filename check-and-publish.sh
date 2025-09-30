#!/bin/bash

AUTHOR="VueTorrent"
REPO="VueTorrent"
REPO_PATH="$AUTHOR/$REPO"

get_latest_version() {
  curl -s "https://api.github.com/repos/$REPO_PATH/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/'
}

get_current_version() {
  if [ -f .docker-publish ]; then
    grep '"version":' .docker-publish | sed -E 's/.*"([^"]+)".*/\1/'
  else
    echo "0.0.0"
  fi
}

CURRENT_VERSION=$(get_current_version)
LATEST_VERSION=$(get_latest_version)

echo "Current version: $CURRENT_VERSION"
echo "Latest version: $LATEST_VERSION"

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "New version available. Updating .docker-publish file."

  # Update .docker-publish file
  cat > .docker-publish <<EOL
{
  "dockerImageName": "ghcr.io/energypatrikhu/vuetorrent",
  "version": "$LATEST_VERSION"
}
EOL
  echo ".docker-publish file updated to version $LATEST_VERSION"

  # Build and push Docker image
  echo "Building and pushing Docker image ghcr.io/energypatrikhu/vuetorrent:$LATEST_VERSION"
  docker build --no-cache -t ghcr.io/energypatrikhu/vuetorrent:$LATEST_VERSION -t ghcr.io/energypatrikhu/vuetorrent:latest .
  docker push ghcr.io/energypatrikhu/vuetorrent:$LATEST_VERSION
  docker push ghcr.io/energypatrikhu/vuetorrent:latest
  echo "Docker image ghcr.io/energypatrikhu/vuetorrent:$LATEST_VERSION built and pushed."

  # Commit and push changes to GitHub
  echo "Committing and pushing changes to GitHub."
  git add .docker-publish
  git commit -m "Update to version $LATEST_VERSION"
  git push origin main
  echo "Changes pushed to GitHub."
else
  echo "No new version available. Current version is up-to-date."
fi
