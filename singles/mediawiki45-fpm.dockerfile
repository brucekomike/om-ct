FROM mediawiki:1.45.1-fpm

ARG CITIZEN_VER=3.12.0
ARG MW_VERSION=REL1_45

ARG EXTENSIONS_REPO_URL="https://github.com/wikimedia/mediawiki-extensions-"
ARG EXTENSIONS_LIST="Popups PreToClip \
ConfirmAccount intersection \
CodeMirror Babel cldr CleanChanges Translate \
UniversalLanguageSelector Interwiki PluggableAuth \
Auth_remoteuser LDAPAuthentication2 \
LDAPAuthorization LDAPGroups LDAPUserInfo \
LDAPProvider LDAPSyncAll"

ARG GIT_VAR="--branch $MW_VERSION --single-branch --depth 1"

WORKDIR /var/www/html/extensions
RUN for extn in $EXTENSIONS_LIST; do \
        echo "Cloning extension: $extn"; \
        git clone "$EXTENSIONS_REPO_URL$extn" "$extn" $GIT_VAR ; \
    done

ARG GIT_VAR="--single-branch --depth 1"

# DynamicPageList3
RUN git clone https://github.com/Universal-Omega/DynamicPageList3.git DynamicPageList3 $GIT_VAR

# TemplateStylesExtender
RUN git clone https://github.com/octfx/mediawiki-extensions-TemplateStylesExtender TemplateStylesExtender $GIT_VAR

# MiscTools
RUN git clone https://github.com/brucekomike/MiscTools MiscTools $GIT_VAR

WORKDIR /var/www/html/skins

# Updated to version 3.12.0
RUN git clone https://github.com/StarCitizenTools/mediawiki-skins-Citizen Citizen $GIT_VAR