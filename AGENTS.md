# PHP Docker Environment - Project Context

## Project Overview
This project provides a comprehensive Docker-based development environment for PHP applications. It is designed to support multiple PHP versions and includes essential tools for database management and AI-assisted development.

### Key Components:
- **PHP Services**: Two separate Apache-based PHP services running PHP 7.4 (`php74`) and PHP 8.2 (`php82`).
- **Database**: MariaDB 10.4.21 (`mariadb`) with a persistent data volume.
- **Management Tools**:
  - **phpMyAdmin**: Web-based MySQL/MariaDB management.
  - **DbGate**: A versatile database manager for various database types.
  - **MailHog**: Email testing tool (Web UI: 8025, SMTP: 1025).
- **CLI Tools (within PHP containers)**:
  - **Composer**: PHP dependency manager.
  - **Node.js (LTS)** and **NPM** (managed via NVM).
  - **Gemini CLI** (`gemini`): For AI-powered terminal workflows.
  - **OpenCode CLI** (`opencode`).
  - **Factory AI CLI** (`factory`).

### Architecture:
- Services are orchestrated using `docker-compose.yml`.
- Both PHP services share the `./src` directory as their document root (`/var/www/html`).
- Persistent data is stored in Docker volumes: `dbgate-data` and `mariadb-data`.

## Building and Running
The environment is managed primarily via Docker Compose.

- **Start Environment**:
  ```bash
  docker compose up -d
  ```
- **Build and Start**:
  ```bash
  ./workspace/scripts/build.sh
  ```
- **Stop Environment**:
  ```bash
  docker compose down
  ```
- **View Logs**:
  ```bash
  docker compose logs -f
  ```
- **Access Services**:
  - PHP 7.4: [http://localhost:8074](http://localhost:8074)
  - PHP 8.2: [http://localhost:8082](http://localhost:8082)
  - phpMyAdmin: [http://localhost:8080](http://localhost:8080)
  - DbGate: [http://localhost:3001](http://localhost:3001)

## Development Conventions
- **Source Code**: All PHP source files should be placed in the `src/` directory.
- **Container Access**: To use the CLI tools (NVM, Gemini CLI, etc.), execute into the desired PHP container:
  ```bash
  docker exec -it php82-apache bash
  ```
- **Database Connectivity**:
  - Use `mariadb` as the hostname when connecting from within the Docker network.
  - Use `localhost` and port `3306` when connecting from the host machine.
  - Credentials:
    - Root: `root` / `root`
    - App DB: `app_db`, User: `db_user`, Pass: `db_pass`
- **Docker Customization**: 
  - Modify `php74.Dockerfile` or `php82.Dockerfile` to install additional PHP extensions or system packages.
  - Ensure any new extensions are also added to the `docker-php-ext-install` command within the Dockerfiles.

- **External Projects (vhosts)**:
  - The root `vhosts/` directory is the one you should use for all external projects.
  - This directory is excluded from git and mapped to `/var/www/vhosts/` in the containers (aliased via Apache).
  - To host a project (e.g., `my-project`), create a subdirectory in the root `vhosts/`.
  - Accessible via `http://localhost:8082/vhosts/my-project`.
  - **Symlinking**: You can symlink external projects into `vhosts/`.
    *   **Host Command**: `ln -s ${HOME}/repos/src/path/to/project ./vhosts/my-site`.
    *   **Note**: For Docker to follow symlinks to *external* directories, the target must also be mounted. This project mirrors `${HOME}/repos/src` to the same path inside the container to support this.
    *   **Tip**: Use `mount --bind` on Linux for more robust cross-volume symlinking.

- **Port Management**:
  - A central port registry is maintained in `src/ports.json`.
  - When adding a new service, you **must** update this file to avoid port conflicts.
  - The registry is accessible via [http://localhost:8082/ports.php](http://localhost:8082/ports.php) (or 8074).
  - Programmatic access (JSON): `http://localhost:8082/ports.php?format=json`.

## Key Files:
- `docker-compose.yml`: Main orchestration file for all services.
- `php74.Dockerfile` & `php82.Dockerfile`: Custom images for PHP versions, including NVM and AI CLI tools.
- `README.md`: Detailed usage instructions and connection details.
- `src/index.php`: Default landing page and PHP info script.
- `workspace/scripts/build.sh`: Helper script for rebuilding and starting.
- `workspace/references/`: Documentation for installed CLI tools.
