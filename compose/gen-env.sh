#!/bin/bash
# process env file
# usage: $0 <env file>
function generate_token() {
  # Generate a random string of 32 alphanumeric characters
  head /dev/urandom | tr -dc A-Za-z0-9_.- | head -c 32
}
function gen_env(){
  source_conf="$1"
  processed_name="${1%.template}"
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
for i in .*.template;do
  gen_env $i
done

gen_yaml zz-compose.yaml compose.yaml
gen_yaml zz-mediawiki.yaml mediawiki.yaml
gen_yaml zz-mediawiki-fpm.yaml mediawiki-fpm.yaml

echo ".env.openldap needs manual adjustments"
