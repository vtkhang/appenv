FROM php:7.4-apache

ARG USER_ID=1000
ARG GROUP_ID=1000

# Update www-data user/group to match host and set home directory
RUN mkdir -p /home/www-data && \
    if [ $(getent group www-data) ]; then groupmod -g $GROUP_ID www-data; else groupadd -g $GROUP_ID www-data; fi \
    && usermod -u $USER_ID -g $GROUP_ID -d /home/www-data -s /bin/bash www-data && \
    chown -R www-data:www-data /home/www-data

# Ensure Apache can still write to its own directories
RUN mkdir -p /var/www/vhosts && chown -R www-data:www-data /var/www/html /var/www/vhosts /var/run/apache2 /var/log/apache2 /etc/apache2

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ripgrep \
    unzip \
    gnupg \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zsh \
    openssh-client \
    default-mysql-client \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mysqli mbstring xml exif

# Install Redis PHP extension
RUN pecl install redis-5.3.7 \
    && docker-php-ext-enable redis

# Configure PHP to use Redis for sessions
RUN echo "session.save_handler = redis" > /usr/local/etc/php/conf.d/session-redis.ini && \
    echo "session.save_path = \"tcp://redis:6379\"" >> /usr/local/etc/php/conf.d/session-redis.ini && \
    echo "session.cookie_domain = .localhost" >> /usr/local/etc/php/conf.d/session-redis.ini && \
    echo "session.cookie_path = /" >> /usr/local/etc/php/conf.d/session-redis.ini && \
    echo "session.cookie_samesite = Lax" >> /usr/local/etc/php/conf.d/session-redis.ini && \
    echo "session.cookie_httponly = On" >> /usr/local/etc/php/conf.d/session-redis.ini

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
ENV TERM xterm-256color

# Set up environment variables for NVM in bashrc and zshrc
RUN echo "export NVM_DIR=\"$NVM_DIR\"" >> /etc/bash.bashrc && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"" >> /etc/bash.bashrc && \
    echo "[ -s \"$NVM_DIR/bash_completion\" ] && . \"$NVM_DIR/bash_completion\"" >> /etc/bash.bashrc && \
    mkdir -p /etc/zsh && \
    echo "export NVM_DIR=\"$NVM_DIR\"" >> /etc/zsh/zshrc && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"" >> /etc/zsh/zshrc && \
    echo "[ -s \"$NVM_DIR/bash_completion\" ] && . \"$NVM_DIR/bash_completion\"" >> /etc/zsh/zshrc

# Install Gemini CLI, OpenCode CLI, and Factory AI CLI
RUN . $NVM_DIR/nvm.sh && \
    npm install -g @google/gemini-cli && \
    npm install -g opencode-ai && \
    curl -fsSL https://opencode.ai/install | bash && \
    curl -fsSL https://app.factory.ai/cli | sh

# Configure Apache to serve /var/www/html by default but fallback to /var/www/vhosts
RUN a2enmod rewrite && \
    echo 'RewriteEngine On' > /etc/apache2/conf-available/vhosts.conf && \
    echo 'Alias /vhosts /var/www/vhosts' >> /etc/apache2/conf-available/vhosts.conf && \
    # 1. If it's a known dashboard file, serve it from /var/www/html (DocumentRoot)
    echo 'RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -f [OR]' >> /etc/apache2/conf-available/vhosts.conf && \
    echo 'RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -d' >> /etc/apache2/conf-available/vhosts.conf && \
    echo 'RewriteRule ^ - [L]' >> /etc/apache2/conf-available/vhosts.conf && \
    # 2. If it's already an internal redirect to /var/www/vhosts, stop
    echo 'RewriteCond %{REQUEST_URI} ^/var/www/vhosts' >> /etc/apache2/conf-available/vhosts.conf && \
    echo 'RewriteRule ^ - [L]' >> /etc/apache2/conf-available/vhosts.conf && \
    # 3. Otherwise, map the request to /var/www/vhosts/ and pass-through
    echo 'RewriteRule ^/(.*) /var/www/vhosts/$1 [L,PT]' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '<Directory /var/www/vhosts>' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '    Options Indexes FollowSymLinks' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '    AllowOverride All' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '    Require all granted' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '</Directory>' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '<Directory /home/varus/repos/src>' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '    Options Indexes FollowSymLinks' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '    AllowOverride All' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '    Require all granted' >> /etc/apache2/conf-available/vhosts.conf && \
    echo '</Directory>' >> /etc/apache2/conf-available/vhosts.conf && \
    a2enconf vhosts

# Install Oh My Zsh for root and set theme to josh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="josh"/' /root/.zshrc && \
    chsh -s /usr/bin/zsh

# Set zsh as default shell for www-data and install Oh My Zsh
RUN chsh -s /usr/bin/zsh www-data && \
    su - www-data -s /bin/zsh -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="josh"/' /home/www-data/.zshrc
