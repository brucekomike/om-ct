# Use an official PHP runtime as a parent image
# Updated to PHP 8.4
FROM php:8.4-fpm

# Set environment variables for MediaWiki version and other configurations
# You can override these at build time or run time
ARG MW_VERSION=REL1_43
ARG CITIZEN_VER=3.12.0 # Updated citizen skin version
ARG DB_USER=your_username
ARG DB_NAME=your_database
# ARG DB_PASS=$(openssl rand -base64 12) # Passwords are better managed with secrets or runtime env vars

# Set up the environment for the build
ENV DEBIAN_FRONTEND=noninteractive
ENV MW_VERSION=$MW_VERSION
ENV CITIZEN_VER=$CITIZEN_VER
ENV DB_USER=$DB_USER
ENV DB_NAME=$DB_NAME
ENV APT_CLI="apt-get install -y --no-install-recommends"
ENV RUN_AS_USER="--user www-data" # Commands will be prefixed with this for clarity, actual execution is handled by entrypoint/scripts.
ENV COMPOSER_HOME="/composer"
ENV PATH="$COMPOSER_HOME/vendor/bin:$PATH"

# Install necessary system packages
# Adjust PHP version in php-fpm socket path if necessary (e.g., php8.4-fpm.sock)
RUN apt-get update && apt-get upgrade -y && \
    $APT_CLI nginx mariadb-client composer php8.4-fpm php8.4-mysql php8.4-xml php8.4-mbstring php8.4-intl php8.4-curl php8.4-apcu php8.4-gd && \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions for MediaWiki (add more as needed from your list)
# Ensure you use the correct PHP version prefix for extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo pdo_mysql opcache

# Set up the web server user and directory
RUN groupadd -r www-data && useradd -r -g www-data www-data
RUN mkdir -p /var/www/html && chown www-data:www-data /var/www/html

# Set up the working directory for MediaWiki
WORKDIR /opt/www

# Clone MediaWiki core
# Using ARG for version allows flexibility during build
ARG MW_VERSION
RUN git clone https://gerrit.wikimedia.org/r/mediawiki/core.git --branch $MW_VERSION --single-branch --depth 1 "mediawiki-$MW_VERSION"
RUN chown -R www-data:www-data /opt/www/mediawiki-$MW_VERSION

# Navigate into the MediaWiki directory
WORKDIR /opt/www/mediawiki-$MW_VERSION

# Update and install vendor libraries using Composer
# Note: Composer dependencies might be better managed in a separate build stage or using pre-built packages.
# This can be time-consuming.
RUN composer install --no-dev --prefer-dist

# Clone and install extensions
# Define extensions here. You can make this dynamic by copying a list from the host.
ENV EXTENSIONS_REPO_URL="https://github.com/wikimedia/mediawiki-extensions-"
# Ensure extensions are compatible with your chosen MW_VERSION (e.g., REL1_43)
ENV EXTENSIONS_LIST="Popups PreToClip \
TemplateStyles ConfirmAccount intersection \
CodeMirror Babel cldr CleanChanges Translate \
UniversalLanguageSelector Interwiki PluggableAuth \
Auth_remoteuser LDAPAuthentication2 \
LDAPAuthorization LDAPGroups LDAPUserInfo \
LDAPProvider LDAPSyncAll PluggableAuth"

RUN mkdir extensions && cd extensions
RUN for extn in $EXTENSIONS_LIST; do \
        echo "Cloning extension: $extn"; \
        git clone "$EXTENSIONS_REPO_URL$extn" "$extn" --branch $MW_VERSION --single-branch --depth 1; \
    done

# Clone and install specific extensions not in the main repo or with different branches
# DynamicPageList3
RUN git clone https://github.com/Universal-Omega/DynamicPageList3.git DPL3 --branch master --single-branch --depth 1 extensions/DynamicPageList3

# TemplateStylesExtender
RUN git clone https://github.com/octfx/mediawiki-extensions-TemplateStylesExtender TemplateStylesExtender --branch master --single-branch --depth 1 extensions/TemplateStylesExtender

# MiscTools
RUN git clone https://github.com/brucekomike/MiscTools MiscTools --branch master --single-branch --depth 1 extensions/MiscTools

# Run composer install for extensions if composer.json exists
RUN cd extensions && find . -name composer.json -exec dirname {} \; | sort -u | while read dir; do \
    echo "Running composer install in $dir"; \
    if [ -d "$dir" ]; then \
        cd "$dir"; \
        composer install --no-dev --prefer-dist; \
        cd ../..; \
    fi; \
done

# Clone and install skins
RUN mkdir ../skins && cd ../skins

# Citizen Skin
# Updated to version 3.12.0
ARG CITIZEN_VER
RUN git clone https://github.com/StarCitizenTools/mediawiki-skins-Citizen --branch $CITIZEN_VER --single-branch --depth 1 Citizen

# Return to the MediaWiki root directory
WORKDIR /opt/www/mediawiki-$MW_VERSION

# Copy LocalSettings.php
# IMPORTANT: You need to create a LocalSettings.php file on your host
# and copy it into the Docker image. This file should contain your database
# connection details (DB_NAME, DB_USER, DB_PASS, DB_HOST) and other configurations.
# Example of what LocalSettings.php might look like (simplified):
# <?php
# $wgDBtype = "mysql";
# $wgDBserver = getenv("DB_HOST"); # Assuming DB_HOST is passed as an env var
# $wgDBname = getenv("DB_NAME");
# $wgDBuser = getenv("DB_USER");
# $wgDBpassword = getenv("DB_PASS");
# $wgGroupPermissions['*']['read'] = true; # Example: Make pages readable
# $wgEnableUploads = true;
# $wgUploadDirectory = "/var/www/html/images";
# $wgUploadPath = "/w/images";
# $wgArticlePath = "/w/$1";
# $wgScriptPath = "/w";
# ... other settings
COPY LocalSettings.php /opt/www/mediawiki-$MW_VERSION/LocalSettings.php

# Create image directory and set permissions
RUN mkdir images && chown www-data:www-data images

# Copy Nginx configuration
# You'll need to create a nginx.conf file for your MediaWiki setup.
# IMPORTANT: Ensure the fastcgi_pass directive points to the correct PHP-FPM socket for PHP 8.4
COPY nginx.conf /etc/nginx/sites-available/default

# Expose port 80 for Nginx
EXPOSE 80

# Volume for images (uploads)
VOLUME /opt/www/mediawiki-$MW_VERSION/images

# Entrypoint script to set up and run the container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]