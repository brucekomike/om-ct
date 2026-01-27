#!/bin/bash
if [[ -f ./.env ]];then
  echo ".env file exists"
else
  env_contents=$(cat .env.template)
  DEFAULT_DOMAIN=$HOSTNAME.local
  eval "echo \"$env_contents\"" | tee .env > /dev/null
  echo ".env file generated"
fi

if [[ -f ./compose.yaml ]];then
  echo "compose file exists"
else
  cp main-template.yaml compose.yaml
  echo "compose.yaml generated"
fi