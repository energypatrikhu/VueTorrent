#!/bin/bash

echo "Checking for updates..."

get_latest_vuetorrent_version() {
  curl -s "https://api.github.com/repos/VueTorrent/VueTorrent/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/'
}

get_latest_qbittorrent_version_lt2() {
  curl -s "https://hub.docker.com/v2/repositories/qbittorrentofficial/qbittorrent-nox/tags?page_size=100&ordering=last_updated" \
    | jq -r '.results[].name' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+-lt2-[0-9]+$' \
    | grep -Ev 'latest|alpha|beta|rc' \
    | head -n1
}

get_latest_qbittorrent_version_standard() {
  curl -s "https://hub.docker.com/v2/repositories/qbittorrentofficial/qbittorrent-nox/tags?page_size=100&ordering=last_updated" \
    | jq -r '.results[].name' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$' \
    | grep -Ev 'lt2|latest|alpha|beta|rc' \
    | head -n1
}

get_current_qbit_version() {
  local variant=$1
  if [ -f .docker-publish ]; then
    jq -r ".versions.$variant // \"0.0.0\"" .docker-publish
  else
    echo "0.0.0"
  fi
}

get_current_vuetorrent_version() {
  if [ -f .docker-publish ]; then
    jq -r '.vuetorrent // "0.0.0"' .docker-publish
  else
    echo "0.0.0"
  fi
}

get_image_name() {
  if [ -f .docker-publish ]; then
    jq -r '.dockerImageName // "ghcr.io/energypatrikhu/vuetorrent"' .docker-publish
  else
    echo "ghcr.io/energypatrikhu/vuetorrent"
  fi
}

IMAGE_NAME=$(get_image_name)
CURRENT_VUETORRENT_VERSION=$(get_current_vuetorrent_version)
LATEST_VUETORRENT_VERSION=$(get_latest_vuetorrent_version)

if [ -z "$LATEST_VUETORRENT_VERSION" ]; then
  echo "Error fetching VueTorrent version. Exiting."
  exit 1
fi

echo "[VueTorrent] Current version: $CURRENT_VUETORRENT_VERSION"
echo "[VueTorrent] Latest version: $LATEST_VUETORRENT_VERSION"

# Check if VueTorrent version changed
VUETORRENT_UPDATED=false
if [ "$CURRENT_VUETORRENT_VERSION" != "$LATEST_VUETORRENT_VERSION" ]; then
  echo "VueTorrent version changed. Updating..."
  jq --arg version "$LATEST_VUETORRENT_VERSION" '.vuetorrent = $version' .docker-publish > .docker-publish.tmp
  mv .docker-publish.tmp .docker-publish
  VUETORRENT_UPDATED=true
fi

# Track if any updates were made
UPDATED=false

# Process lt2 variant
echo ""
echo "=== Checking lt2 variant ==="
CURRENT_QBIT_VERSION_LT2=$(get_current_qbit_version "lt2")
LATEST_QBIT_VERSION_LT2=$(get_latest_qbittorrent_version_lt2)

if [ -z "$LATEST_QBIT_VERSION_LT2" ]; then
  echo "Error fetching latest qBittorrent lt2 version. Skipping lt2 variant."
else
  echo "[qBittorrent lt2] Current version: $CURRENT_QBIT_VERSION_LT2"
  echo "[qBittorrent lt2] Latest version: $LATEST_QBIT_VERSION_LT2"

  # Build full version tag by concatenating qBit and VueTorrent versions
  FULL_VERSION_LT2="${LATEST_QBIT_VERSION_LT2}_${LATEST_VUETORRENT_VERSION}"

  if [ "$CURRENT_QBIT_VERSION_LT2" != "$LATEST_QBIT_VERSION_LT2" ] || [ "$VUETORRENT_UPDATED" = true ]; then
    echo "Update detected (qBit: $CURRENT_QBIT_VERSION_LT2 -> $LATEST_QBIT_VERSION_LT2, VueTorrent: $CURRENT_VUETORRENT_VERSION -> $LATEST_VUETORRENT_VERSION)"
    echo "Building and pushing lt2 variant..."

    # Build and push Docker image for lt2
    docker build --no-cache --build-arg QBIT_TAG=$LATEST_QBIT_VERSION_LT2 \
      -t $IMAGE_NAME:$FULL_VERSION_LT2 \
      -t $IMAGE_NAME:latest-lt2 .
    docker push $IMAGE_NAME:$FULL_VERSION_LT2
    docker push $IMAGE_NAME:latest-lt2
    echo "Docker image $IMAGE_NAME:$FULL_VERSION_LT2 built and pushed."

    # Update the JSON for lt2 (store only qBit version)
    jq --arg version "$LATEST_QBIT_VERSION_LT2" '.versions.lt2 = $version' .docker-publish > .docker-publish.tmp
    mv .docker-publish.tmp .docker-publish
    UPDATED=true
  else
    echo "lt2 variant is up-to-date."
  fi
fi

# Process standard variant
echo ""
echo "=== Checking standard variant ==="
CURRENT_QBIT_VERSION_STANDARD=$(get_current_qbit_version "standard")
LATEST_QBIT_VERSION_STANDARD=$(get_latest_qbittorrent_version_standard)

if [ -z "$LATEST_QBIT_VERSION_STANDARD" ]; then
  echo "Error fetching latest qBittorrent standard version. Skipping standard variant."
else
  echo "[qBittorrent standard] Current version: $CURRENT_QBIT_VERSION_STANDARD"
  echo "[qBittorrent standard] Latest version: $LATEST_QBIT_VERSION_STANDARD"

  # Build full version tag by concatenating qBit and VueTorrent versions
  FULL_VERSION_STANDARD="${LATEST_QBIT_VERSION_STANDARD}_${LATEST_VUETORRENT_VERSION}"

  if [ "$CURRENT_QBIT_VERSION_STANDARD" != "$LATEST_QBIT_VERSION_STANDARD" ] || [ "$VUETORRENT_UPDATED" = true ]; then
    echo "Update detected (qBit: $CURRENT_QBIT_VERSION_STANDARD -> $LATEST_QBIT_VERSION_STANDARD, VueTorrent: $CURRENT_VUETORRENT_VERSION -> $LATEST_VUETORRENT_VERSION)"
    echo "Building and pushing standard variant..."

    # Build and push Docker image for standard
    docker build --no-cache --build-arg QBIT_TAG=$LATEST_QBIT_VERSION_STANDARD \
      -t $IMAGE_NAME:$FULL_VERSION_STANDARD \
      -t $IMAGE_NAME:latest .
    docker push $IMAGE_NAME:$FULL_VERSION_STANDARD
    docker push $IMAGE_NAME:latest
    echo "Docker image $IMAGE_NAME:$FULL_VERSION_STANDARD built and pushed."

    # Update the JSON for standard (store only qBit version)
    jq --arg version "$LATEST_QBIT_VERSION_STANDARD" '.versions.standard = $version' .docker-publish > .docker-publish.tmp
    mv .docker-publish.tmp .docker-publish
    UPDATED=true
  else
    echo "Standard variant is up-to-date."
  fi
fi

# Commit and push changes if any updates were made
if [ "$UPDATED" = true ]; then
  echo ""
  echo "Committing and pushing changes to GitHub."
  git add .docker-publish
  git commit -m "Update versions: VueTorrent=$LATEST_VUETORRENT_VERSION, lt2=${LATEST_QBIT_VERSION_LT2:-unchanged}, standard=${LATEST_QBIT_VERSION_STANDARD:-unchanged}"
  git push origin main
  echo "Changes pushed to GitHub."
else
  echo ""
  echo "No new versions available. All variants are up-to-date."
fi
