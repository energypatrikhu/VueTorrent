FROM qbittorrentofficial/qbittorrent-nox:latest

#  Install dependencies
RUN apk add --no-cache curl unzip

# Download original entrypoint.sh script
# https://github.com/qbittorrent/docker-qbittorrent-nox/blob/main/entrypoint.sh
RUN curl -L https://raw.githubusercontent.com/qbittorrent/docker-qbittorrent-nox/main/entrypoint.sh -o /entrypoint.sh && \
  chmod +x /entrypoint.sh

# Patch entrypoint.sh to include VueTorrent skin auto updater
COPY vuetorrent-updater.sh /vuetorrent-updater.sh
RUN sed -i $'s|#!/bin/sh|#!/bin/sh\\n\\n# VueTorrent skin updater\\nsh /vuetorrent-updater.sh|' /entrypoint.sh

# Patch entrypoint.sh to set the Preferences section
RUN sed -i $'s|\\[BitTorrent\\]|[Preferences]\\nWebUI\\\\AlternativeUIEnabled=true\\nWebUI\\\\RootFolder=/vuetorrent\\n\\n[BitTorrent]|' /entrypoint.sh
