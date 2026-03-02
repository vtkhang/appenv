# PHP Docker Environment

This setup provides two Apache services, each running a different PHP version:

* **PHP 7.4 Apache** (Service: `php74`): Accessible at <http://localhost:8074>
* **PHP 8.2 Apache** (Service: `php82`): Accessible at <http://localhost:8082>
* **phpMyAdmin** (Service: `phpmyadmin`): Accessible at <http://localhost:8080>
* **DbGate** (Service: `dbgate`): Accessible at <http://localhost:3001>
* **MariaDB 10.4** (Service: `mariadb`): Accessible at `localhost:3306`

Both services share the same `src/` directory as their document root.

### CLI Tools

The PHP containers include the following CLI tools:
*   **Node.js (LTS)** & **NPM** (via NVM)
*   **Gemini CLI** (`gemini`)
*   **OpenCode CLI** (`opencode`)
*   **Factory AI CLI** (`factory`)

## How to use

1.  **Start the environment:**
    ```bash
    docker compose up -d
    ```

2.  **Access Database Management Tools:**
    *   **phpMyAdmin:** Open <http://localhost:8080> and enter the MySQL/MariaDB server host (`mariadb`), username (`root`), and password (`root`).
    *   **DbGate:** Open <http://localhost:3001> to manage various database types.

3.  **MariaDB Connection Details:**
    *   **Host:** `mariadb` (within Docker network) or `localhost` (from your machine)
    *   **Port:** `3306`
    *   **Root Password:** `root`
    *   **Default Database:** `app_db`
    *   **Default User:** `db_user`
    *   **Default Password:** `db_pass`

4.  **View logs:**
    ```bash
    docker compose logs -f
    ```

5.  **Stop the environment:**
    ```bash
    docker compose down
    ```

## Customizing Extensions

If you need to install PHP extensions (e.g., `mysqli`, `pdo_mysql`, `gd`), you can create custom Dockerfiles and update `docker-compose.yml`.

Example `Dockerfile`:
```dockerfile
FROM php:8.2-apache
RUN docker-php-ext-install mysqli pdo pdo_mysql
```
