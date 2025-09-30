FROM alpine:latest AS downloader

# Install dependencies
RUN apk add --no-cache curl unzip

# Download VueTorrent
RUN curl -L -o /tmp/vuetorrent.zip https://github.com/VueTorrent/VueTorrent/releases/latest/download/vuetorrent.zip && \
  unzip /tmp/vuetorrent.zip -d /tmp/vuetorrent && \
  rm /tmp/vuetorrent.zip

FROM qbittorrentofficial/qbittorrent-nox:latest

# Copy VueTorrent skin to the appropriate directory
COPY --from=downloader /tmp/vuetorrent /vuetorrent

# Patch entrypoint.sh to set the Preferences section
RUN sed -i $'s|\\[BitTorrent\\]|[Preferences]\\nWebUI\\\\AlternativeUIEnabled=true\\nWebUI\\\\RootFolder=/vuetorrent\\n\\n[BitTorrent]|' /entrypoint.sh
