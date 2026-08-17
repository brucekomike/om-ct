#!/bin/bash
cd "$(dirname "$0")"

if [ -f ../nginx-templates/.env ]; then
  echo "Loading environment variables from ../nginx-templates/.env"
  source ../nginx-templates/.env
elif [ -f ../nginx-templates-ssl/.env ]; then
  echo "Fallback: loading environment variables from ../nginx-templates-ssl/.env"
  source ../nginx-templates-ssl/.env
else
  echo "Error: no .env found in ../nginx-templates or ../nginx-templates-ssl."
  exit 1
fi

site_list=()
for enabled_site in "${nginx_config_list[@]}"; do
  case "$enabled_site" in
    "wiki.conf"|"wiki-fpm.conf"|"wikifpm.conf")
      site_list+=("$WIKIURL")
      ;;
    "gitlab.conf")
      site_list+=("$GITLABURL")
      ;;
    "cloud.conf")
      site_list+=("$CLOUDURL")
      ;;
    "overleaf.conf")
      site_list+=("$OVERLEAFURL")
      ;;
    "keycloak.conf")
      site_list+=("$KEYCLOAKURL")
      ;;
    "weblate.conf")
      site_list+=("$WEBLATEURL")
      ;;
    "dev-ct.conf")
      site_list+=("$DEVCTURL")
      ;;
    "pve.conf")
      site_list+=("$PVEURL")
      ;;
    "00-realip.conf")
      # snippet, not a site
      ;;
    *)
      echo "Warning: Unknown site '$enabled_site' in nginx_config_list. Skipping."
      ;;
  esac
done
for doc_site in "${nginx_doc_list[@]}"; do
  site_list+=("$doc_site"."$MAIN_DOMAIN")
done
site_url_text=$(printf "\"%s\",\n" "${site_list[@]}" )
site_url_text=${site_url_text%,}
echo -e "$site_url_text"

function gen_env(){
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

mkdir -p ../frp/conf.d
gen_env frpc.toml ../frp/frpc.toml
gen_env frps.toml ../frp/frps.toml
gen_env conf.d/frpc.toml ../frp/conf.d/frpc.toml
