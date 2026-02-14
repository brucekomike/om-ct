#!/bin/bash
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
if [ -f .env ]; then
  echo "Loading environment variables from .env file..."
  . .env
else
  echo "No .env file found. copying from .env.template"
  cp .env.template .env
  exit 1
fi
for config in "${nginx_config_list[@]}"; do
  echo "Copying $config to ngiox dir"
  gen_env "$config" ../nginx/$config
done