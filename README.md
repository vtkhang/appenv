# 🚀 AppEnv: The AI-Ready, Multi-PHP Development Stack

*AppEnv* is a high-performance, portable Docker environment designed for modern PHP developers. It combines legacy support with modern AI-assisted workflows, providing a seamless bridge between your host machine and containerized services.

## ✨ Key Features

*   *Dual PHP Environments*: Run and test applications simultaneously on *PHP 7.4* and *PHP 8.2* using dedicated Apache containers.
*   *AI-First Terminal*: Pre-integrated with *Gemini CLI*, *OpenCode CLI*, and *Factory AI CLI* to power your terminal-based AI workflows.
*   *Advanced Database Management*: Includes *MariaDB 10.4*, *phpMyAdmin* (with arbitrary host support), and *DbGate* for a versatile data management experience.
*   *Email Testing*: *MailHog* captures all outgoing emails for local inspection.
*   *Zero-Pollution Vhosts*: A dedicated `vhosts/` directory allows you to host any external project via symlinks without cluttering the core repository.
*   *Path Mirroring*: Automatically mirrors `${HOME}/repos/src` into the containers, ensuring that absolute symlinks work perfectly across different machines.
*   *Smart Port Registry*: Built-in tracking of all allocated ports via `ports.json` and a web-based registry.
*   *Node.js & PHP Ecosystem*: Full *NVM* integration with *Node.js LTS*, *NPM*, and *Composer* pre-installed.

## 🛠 Architecture

The environment is built for portability and cleanliness. By using an Apache *Alias* for the `vhosts` directory and mirroring the user's home path, it provides a "XAMPP-like" experience with the isolation and power of Docker.

## 🚀 How to use

1.  **Start the environment:**
    ```bash
    docker compose up -d
    ```

2.  **Access Database Management Tools:**
    *   **phpMyAdmin:** Open <http://localhost:8080> and enter the MySQL/MariaDB server host (`mariadb`), username (`root`), and password (`root`).
    *   **DbGate:** Open <http://localhost:3001> to manage various database types.
    *   **MailHog:** Open <http://localhost:8025> to view captured emails.

3.  **MariaDB Connection Details:**
    *   **Host:** `mariadb` (within Docker network) or `localhost` (from your machine)
    *   **Port:** `3306`
    *   **Root Password:** `root`
    *   **Default Database:** `app_db`
    *   **Default User:** `db_user`
    *   **Default Password:** `db_pass`

4.  **MailHog SMTP Settings:**
    *   **Host:** `mailhog` (within Docker network) or `localhost` (from your machine)
    *   **Port:** `1025`
    *   **Encryption:** None / Cleartext

5.  **View logs:**
    ```bash
    docker compose logs -f
    ```

6.  **Stop the environment:**
    ```bash
    docker compose down
    ```

## 📄 License

This project is open-sourced under the [MIT License](LICENSE).

If you need to install PHP extensions (e.g., `mysqli`, `pdo_mysql`, `gd`), you can create custom Dockerfiles and update `docker-compose.yml`.

Example `Dockerfile`:
```dockerfile
FROM php:8.2-apache
RUN docker-php-ext-install mysqli pdo pdo_mysql
```
