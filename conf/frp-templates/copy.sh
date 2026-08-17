#!/bin/bash
# Generate nginx confs and frp configs from all template dirs:
#   nginx-templates, nginx-templates-ssl, frp-templates (this dir)
cd "$(dirname "$0")"

# ---- env: create .env from .env.template if missing, then load ----
for dir in ../nginx-templates ../nginx-templates-ssl; do
  if [ -f "$dir/.env" ]; then
    echo "Loading environment variables from $dir/.env"
  elif [ -f "$dir/.env.template" ]; then
    echo "Creating $dir/.env from .env.template (edit it for your site)"
    cp "$dir/.env.template" "$dir/.env"
  else
    echo "Warning: no .env or .env.template in $dir"
    continue
  fi
  source "$dir/.env"
done

# ---- run the nginx copy scripts to generate ../nginx/*.conf ----
for dir in ../nginx-templates ../nginx-templates-ssl; do
  if [ -x "$dir/copy.sh" ]; then
    echo "=== processing $dir ==="
    (cd "$dir" && ./copy.sh)
  fi
done

# ---- collect enabled site urls from both nginx envs ----
collect_sites() {
  local dir="$1"
  (source "$dir/.env"
   for enabled_site in "${nginx_config_list[@]}"; do
     case "$enabled_site" in
       "wiki.conf"|"wiki-fpm.conf"|"wikifpm.conf")
         echo "$WIKIURL"
         ;;
       "gitlab.conf")
         echo "$GITLABURL"
         ;;
       "cloud.conf")
         echo "$CLOUDURL"
         ;;
       "overleaf.conf")
         echo "$OVERLEAFURL"
         ;;
       "keycloak.conf")
         echo "$KEYCLOAKURL"
         ;;
       "weblate.conf")
         echo "$WEBLATEURL"
         ;;
       "dev-ct.conf")
         echo "$DEVCTURL"
         ;;
       "pve.conf")
         echo "$PVEURL"
         ;;
       "00-realip.conf")
         # snippet, not a site
         ;;
       *)
         echo "Warning: Unknown site '$enabled_site' in $dir/.env. Skipping." >&2
         ;;
     esac
   done
   for doc_site in "${nginx_doc_list[@]}"; do
     [ -n "$MAIN_DOMAIN" ] && echo "$doc_site.$MAIN_DOMAIN"
   done)
}

site_list=()
for dir in ../nginx-templates ../nginx-templates-ssl; do
  [ -f "$dir/.env" ] || continue
  while read -r url; do
    [ -n "$url" ] && site_list+=("$url")
  done < <(collect_sites "$dir")
done
# dedupe
site_list=($(printf '%s\n' "${site_list[@]}" | sort -u))
if [ ${#site_list[@]} -eq 0 ]; then
  echo "Warning: no sites enabled; frp customDomains will be empty"
fi
site_url_text=$(printf "\"%s\"\n" "${site_list[@]}" | paste -sd ",\n" -)
echo "$site_url_text"

# ---- generate frp configs ----
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
