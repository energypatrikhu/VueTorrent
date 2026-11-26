ARG QBIT_TAG=latest

FROM qbittorrentofficial/qbittorrent-nox:${QBIT_TAG}

# Install ca-certificates and update certificates
RUN apk add --no-cache ca-certificates \
  && update-ca-certificates \
  && rm -rf /var/cache/apk/*   

# Download VueTorrent and extract to root
RUN curl -L -o /tmp/vuetorrent.zip https://github.com/VueTorrent/VueTorrent/releases/latest/download/vuetorrent.zip && \
  unzip /tmp/vuetorrent.zip -d / && \
  rm -rfv /tmp/vuetorrent.zip

# Patch entrypoint.sh to set the Preferences section
RUN sed -i $'s|\\[BitTorrent\\]|[Preferences]\\nWebUI\\\\AlternativeUIEnabled=true\\nWebUI\\\\RootFolder=/vuetorrent\\n\\n[BitTorrent]|' /entrypoint.sh
