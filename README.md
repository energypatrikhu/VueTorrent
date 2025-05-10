# VueTorrent Docker Image

This repository contains a custom Docker image for running qBittorrent with the VueTorrent WebUI skin. Below is a summary of the modifications made to the base `qbittorrentofficial/qbittorrent-nox` image:

## Features Added

1. **VueTorrent Skin Auto-Updater**
   - A script (`vuetorrent-updater.sh`) is included to automatically download and update the VueTorrent WebUI skin from its latest release on GitHub.
   - The script checks for the latest version, downloads it if necessary.

2. **Patched `entrypoint.sh`**
   - The original `entrypoint.sh` script from the base image is patched to:
     - Run the VueTorrent updater script during container startup.
     - Enable the VueTorrent WebUI by setting the following preferences:
       - `WebUI\AlternativeUIEnabled=true`
       - `WebUI\RootFolder=/vuetorrent`

3. **Dependencies Installed**
   - Added `curl` and `unzip` to the image to support downloading and extracting the VueTorrent skin.

## How It Works

1. On container startup, the `vuetorrent-updater.sh` script checks if the VueTorrent WebUI is installed and up-to-date.
2. If the WebUI is missing or outdated, the script downloads the latest version from the VueTorrent GitHub repository and updates the `/vuetorrent` directory.
3. The patched `entrypoint.sh` ensures the VueTorrent WebUI is enabled and configured correctly.

## Usage

To build and run the Docker image:

```bash
# Option 1: Build the Docker image locally
docker build -t vuetorrent .

# Option 2: Use the prebuilt image from Docker Hub
docker pull energyhun24/vuetorrent

# Run the Docker container
docker run -d -p 8080:8080 vuetorrent
```

The WebUI will be accessible at `http://localhost:8080` with the VueTorrent skin enabled.
## Additional Information

For more details about the base Docker image used in this project, visit the official [Docker Hub](https://hub.docker.com/r/qbittorrentofficial/qbittorrent-nox) page or check out its [GitHub repository](https://github.com/qbittorrent/docker-qbittorrent-nox).

## Notes

- Ensure that the container has internet access to download the VueTorrent WebUI updates.
- The `vuetorrent-updater.sh` script handles versioning to avoid unnecessary downloads.

## Credits
- [VueTorrent skin](https://github.com/VueTorrent/VueTorrent)
- [qBittorrent](https://www.qbittorrent.org/)