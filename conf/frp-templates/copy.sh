#!/bin/bash
if [ -f ../nginx-templates/.env ]; then
  echo "Loading environment variables from ../nginx-templates/.env"
  source ../nginx-templates/.env
else
  echo "Error: ../nginx-templates/.env file not found."
  exit 1
fi
site_list=()
for enabled_site in "${nginx_config_list[@]}"; do
  case "$enabled_site" in
    "wiki.conf")
      site_list+=("$WIKIURL")
      ;;
    "wiki-fpm.conf")
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
    *)
      echo "Warning: Unknown site '$enabled_site' in nginx_config_list. Skipping."
      ;;
  esac
done
site_url_text=$(printf "\"%s\"\n" "${site_list[@]}" | paste -sd ",\n" -)
echo $site_url_text

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
gen_env conf.d/frpc.toml ../frp/conf.d/frpc.toml