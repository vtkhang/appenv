#!/bin/bash

# Ensure we are in the project root
cd "$(dirname "$0")"

# Generate .env if it doesn't exist or update it
echo "Updating .env with current user UID/GID..."
echo "USER_ID=$(id -u)" > .env
echo "GROUP_ID=$(id -g)" >> .env

echo "Checking permissions for vhosts and src..."
mkdir -p vhosts src
# Only use sudo to fix ownership if the directories are currently owned by root
if [ "$(stat -c '%u' vhosts)" = "0" ] || [ "$(stat -c '%u' src)" = "0" ]; then
    echo "Detected root-owned directories. Fixing ownership..."
    sudo chown -R $(id -u):$(id -g) vhosts src
fi

echo "Checking certificates..."

# Clean up if they were accidentally created as directories
if [ -d "selfsigned.crt" ]; then
    echo "Removing invalid selfsigned.crt directory..."
    rm -rf selfsigned.crt
fi

if [ -d "selfsigned.key" ]; then
    echo "Removing invalid selfsigned.key directory..."
    rm -rf selfsigned.key
fi

# Generate certificates if they don't exist
if [ ! -f "selfsigned.crt" ] || [ ! -f "selfsigned.key" ]; then
    echo "Generating self-signed certificates..."
    openssl req -x509 -newkey rsa:4096 -keyout selfsigned.key -out selfsigned.crt -sha256 -days 3650 -nodes -subj "/C=XX/ST=State/L=City/O=Company/OU=Unit/CN=localhost"
    echo "Certificates generated."
else
    echo "Certificates already exist."
fi

echo "Starting/Reloading Docker Compose stack..."
docker compose up -d --build

echo "Stack is up. Checking Caddy status..."
docker compose ps caddy
