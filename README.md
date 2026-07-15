# 7 Days to Die Dedicated Server (Dockerized)

This repository provides a production-ready Docker environment for hosting a **7 Days to Die** dedicated server. It simplifies the setup process by handling permission management, initial game file installation, and automated logging through a multi-container architecture.

## Features

-   🚀 **Automated Setup**: Includes an initialization sequence that sets up correct directory permissions (`init-perms`) before starting the server.
-   📦 **Pre-built Images**: Uses specialized base containers for Steam environments to ensure compatibility.
-   🛠️ **Scripted Management**: Comes with built-in scripts for starting and stopping (gracefully).
-   📊 **Logging & Monitoring**: Automatic log rotation/tailing that filters out noise while providing a clear output of the server's status.
-   ☸️ **Kubernetes Ready**: Includes Helm charts in `/deploy` for deploying to K8s clusters.

## Prerequisites

- [Docker](https://docs.docker.com/engine/) installed on your host machine.
- [Docker Compose](https://compose.github.io/) or `docker bake`.

## Quick Start (Docker Compose)

The easiest way to get started is using the provided Docker Compose configuration.

1.  **Clone this repository**:
    ```bash
    git clone <repository_url>
    cd 7dtd
    ```

2.  **Launch the server**:
    Run the following command to build and start the services:
    ```bash
    docker compose up -d --build
    ```

### Services Overview
-   `init-perms`: Creates `/data` and `/home/steam` directories with correct ownership (user 1000).
-   `init-game-files`: Runs the initial game installation script. This service completes before the server starts.
-   `sdtd`: The main dedicated server container running on persistent volumes.

## Ports Mapping

| Port | Protocol | Description |
|------|----------|-------------|
| `26900` | TCP | Game Server Traffic |
| `26900-26904` | UDP | Game Server Traffic |
| `8080` | TCP | Dashboard (if enabled) |
| `8081` | TCP | Telnet access (if enabled) |

## Configuration

### Volumes
The server persists data using the following volumes:
-   `game-data`: Stores all game saves, configurations, and assets.
-   `steam`: Stores SteamCMD files and shared libraries.

To customize your configuration, you can mount a local `serverconfig.xml` file to the container or modify environment variables in `docker-compose.yml`.

### Shell Scripts Reference
The project includes several scripts for manual intervention:
-   [`start-server.sh`](./start-server.sh): Starts the server with batchmode, no graphics, and specific log configurations.
-   [`stop-server.sh`](./stop-server.sh): Gracefully shuts down the game process (use as needed).

## Advanced Deployment: Kubernetes / Helm

For users looking to deploy on a cluster, see the [7dtd](https://github.com/thelande/charts/tree/main/charts/7dtd) chart.

## License
Refer to the [LICENSE](./LICENSE) file for more details on usage rights.
