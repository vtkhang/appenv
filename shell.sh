#!/bin/bash

SERVICE=${1:-php82}

if [ "$SERVICE" == "php74" ] || [ "$SERVICE" == "php82" ]; then
    docker compose exec -u www-data $SERVICE zsh
else
    docker compose exec $SERVICE bash
fi
