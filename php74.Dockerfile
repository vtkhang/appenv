FROM php:7.4-apache

ARG USER_ID=1000
ARG GROUP_ID=1000

# Update www-data user/group to match host
RUN if [ $(getent group www-data) ]; then groupmod -g $GROUP_ID www-data; else groupadd -g $GROUP_ID www-data; fi \
    && usermod -u $USER_ID -g $GROUP_ID www-data

# Ensure Apache can still write to its own directories
RUN chown -R www-data:www-data /var/www/html /var/run/apache2 /var/log/apache2 /etc/apache2

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install NVM and Node.js (LTS)
ENV NVM_DIR /usr/local/nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install --lts && \
    nvm use --lts && \
    nvm alias default 'lts/*'

# Add Node and NPM to PATH
# Using a wildcard to match any version installed under versions/node
RUN ln -s $NVM_DIR/versions/node/$(ls $NVM_DIR/versions/node | head -n 1) $NVM_DIR/current
ENV PATH $NVM_DIR/current/bin:$PATH

# Set up environment variables for NVM in bashrc
RUN echo "export NVM_DIR=\"$NVM_DIR\"" >> /etc/bash.bashrc && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"" >> /etc/bash.bashrc && \
    echo "[ -s \"$NVM_DIR/bash_completion\" ] && . \"$NVM_DIR/bash_completion\"" >> /etc/bash.bashrc

# Install Gemini CLI, OpenCode CLI, and Factory AI CLI
RUN . $NVM_DIR/nvm.sh && \
    npm install -g @google/gemini-cli && \
    npm install -g opencode-ai && \
    curl -fsSL https://opencode.ai/install | bash && \
    curl -fsSL https://app.factory.ai/cli | sh

# Configure Apache to Alias /vhosts to /var/www/vhosts
RUN echo 'Alias /vhosts /var/www/vhosts' > /etc/apache2/conf-available/vhosts.conf && \
    echo '<Directory /var/www/vhosts>' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '    Options Indexes FollowSymLinks' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '    AllowOverride All' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '    Require all granted' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '</Directory>' >> /etc/apache2/conf-available/vhosts.conf && \
    a2enconf vhosts
