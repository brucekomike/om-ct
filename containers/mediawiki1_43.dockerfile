# Use an official PHP runtime as a parent image
# Updated to PHP 8.4
FROM debian:13.0

# Set environment variables for MediaWiki version and other configurations
# You can override these at build time or run time
ARG CITIZEN_VER=3.12.0
ARG MW_VERSION=REL1_43

# Clone and install extensions
# Define extensions here. You can make this dynamic by copying a list from the host.
ARG EXTENSIONS_REPO_URL="https://github.com/wikimedia/mediawiki-extensions-"
# Ensure extensions are compatible with your chosen MW_VERSION (e.g., REL1_43)
ARG EXTENSIONS_LIST="Popups PreToClip \
TemplateStyles ConfirmAccount intersection \
CodeMirror Babel cldr CleanChanges Translate \
UniversalLanguageSelector Interwiki PluggableAuth \
Auth_remoteuser LDAPAuthentication2 \
LDAPAuthorization LDAPGroups LDAPUserInfo \
LDAPProvider LDAPSyncAll PluggableAuth"

ARG RUN
ARG GIT_VAR="--branch $MW_VERSION --single-branch --depth 1"
RUN apt update && apt upgrade
RUN apt install git php-fpm php php-mysql php-xml php-mbstring \
    php-intl php-curl php-apcu php-gd composer
# Navigate into the MediaWiki directory

WORKDIR /var/www
RUN git clone https://gerrit.wikimedia.org/r/mediawiki/core.git \
$git_var mediawiki-$mw_version

WORKDIR
RUN for extn in $EXTENSIONS_LIST; do \
        echo "Cloning extension: $extn"; \
        git clone "$EXTENSIONS_REPO_URL$extn" "$extn" $GIT_VAR ; \
    done

# Clone and install specific extensions not in the main repo or with different branches
ARG GIT_VAR="--single-branch --depth 1"

# DynamicPageList3
RUN git clone https://github.com/Universal-Omega/DynamicPageList3.git DynamicPageList3 $GIT_VAR

# TemplateStylesExtender
RUN git clone https://github.com/octfx/mediawiki-extensions-TemplateStylesExtender TemplateStylesExtender $GIT_VAR

# MiscTools
RUN git clone https://github.com/brucekomike/MiscTools MiscTools $GIT_VAR

# Citizen Skin
WORKDIR /var/www/html/skins
# Updated to version 3.12.0
RUN git clone https://github.com/StarCitizenTools/mediawiki-skins-Citizen Citizen $GIT_VAR

