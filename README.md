# VueTorrent Docker Image

This repository contains a custom Docker image for running qBittorrent with the VueTorrent WebUI skin. Below is a summary of the modifications made to the base `qbittorrentofficial/qbittorrent-nox` image:

## Features Added

- **VueTorrent WebUI Skin**: The latest version of the VueTorrent skin is downloaded and installed in the `/vuetorrent` directory.

## How It Works

1. During container build, the Dockerfile downloads the latest VueTorrent skin from the official GitHub releases.
2. The skin is extracted and placed in the `/vuetorrent` directory within the container.
3. The patched `entrypoint.sh` ensures the VueTorrent WebUI is enabled and configured correctly.

## Usage

To build and run the Docker image:

```bash
# Option 1: Build the Docker image locally
docker build -t vuetorrent .

# Option 2: Use the prebuilt image from Docker Hub
docker pull ghcr.io/energypatrikhu/vuetorrent:latest
```

# Running the Container
For more details on running the container, refer to the [qbittorrent-nox Docker image documentation](https://hub.docker.com/r/qbittorrentofficial/qbittorrent-nox).


The WebUI will be accessible at `http://localhost:8080` with the VueTorrent skin enabled.
## Additional Information

For more details about the base Docker image used in this project, visit the official [Docker Hub](https://hub.docker.com/r/qbittorrentofficial/qbittorrent-nox) page or check out its [GitHub repository](https://github.com/qbittorrent/docker-qbittorrent-nox).

## Credits
- [VueTorrent skin](https://github.com/VueTorrent/VueTorrent)
- [qBittorrent](https://www.qbittorrent.org/)
