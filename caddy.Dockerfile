FROM caddy:latest

# Install libnss3-tools to support certificate trust store operations
RUN apk add --no-cache nss-tools
