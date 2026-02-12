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

for i in .*.template;do
  gen_env $i
done

# process compose file
if [[ -f ./compose.yaml ]];then
  echo "compose file exists"
else
  cp main-template.yaml compose.yaml
  echo "compose.yaml generated"
fi
if [[ -f ./mediawiki.yaml ]];then
  echo "mediawiki.yaml exists"
else
  cp zz-mediawiki.yaml mediawiki.yaml
  echo "mediawiki.yaml generated"
fi