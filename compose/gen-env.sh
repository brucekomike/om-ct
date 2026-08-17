#!/bin/bash
# process env file
# usage: $0 <env file>
function generate_token() {
  # Generate a random string of 32 alphanumeric characters
  head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 32
}
function gen_env(){
  source_conf="$1"
  processed_name="${2:-${1%.template}}"
  if [[ -f $processed_name ]];then
    echo "$processed_name exists"
  else
    env_contents=$(cat $source_conf)
    eval "echo \"$env_contents\"" | tee $processed_name > /dev/null
    echo "$processed_name file generated"
  fi
}
function gen_yaml(){
  source_conf="$1"
  processed_name="$2"
  if [[ -f $processed_name ]];then
    echo "$processed_name exists"
  else
    env_contents=$(cat $source_conf)
    eval "echo \"$env_contents\"" | tee $processed_name > /dev/null
    echo "$processed_name file generated"
  fi
}
source ../conf/nginx-templates-ssl/.env
for i in templates/.*.template;do
  gen_env "$i" "$(basename "$i" .template)"
done

gen_yaml templates/zz-compose.yaml compose.yaml
gen_yaml templates/zz-mediawiki.yaml mediawiki.yaml
gen_yaml templates/zz-mediawiki-fpm.yaml mediawiki-fpm.yaml
gen_yaml templates/zz-nginx.yaml nginx.yaml
gen_yaml templates/zz-nginx-certbot.yaml nginx-certbot.yaml
gen_yaml templates/zz-gitlab.yaml gitlab.yaml
gen_yaml templates/zz-nextcloud.yaml nextcloud.yaml
gen_yaml templates/zz-keycloak.yaml keycloak.yaml
gen_yaml templates/zz-openldap.yaml openldap.yaml
gen_yaml templates/zz-weblate.yaml weblate.yaml
gen_yaml templates/zz-frp-client.yaml frp-client.yaml
gen_yaml templates/zz-frp-server.yaml frp-server.yaml
# standalone variants (dev/test)
gen_yaml templates/za-nextcloud.yaml za-nextcloud.yaml
gen_yaml templates/zb-keycloak.yaml zb-keycloak.yaml
gen_yaml templates/zz-dev-ct.yaml dev-ct.yaml

echo ".env.openldap needs manual adjustments"
