#!/bin/bash

# test if ldapadd command exists
if ! [[ $(command -v ldapadd) ]];then
  echo "try install ldap-utils"
  exit 1
fi

. ../../compose/.env.openldap
. ../nginx-templates-ssl/.env
domain=$MURL
ldap_dn=$(echo "$domain" | awk -F'.' '{OFS=","; for(i=1; i<=NF; i++) printf "dc=%s%s", $i, (i==NF ? "" : ",")}')
echo "Domain: $domain"
echo "LDAP DN: $ldap_dn"

ldapadd -x -D "uid=admin,$ldap_dn" -w $LDAP_INIT_ROOT_USER_PW -H ldap://localhost -f bootstrap.ldif
ldapadd -x -D "uid=admin,$ldap_dn" -w $LDAP_INIT_ROOT_USER_PW -H ldap://localhost -f memberof2.ldif
ldapadd -x -D "uid=admin,$ldap_dn" -w $LDAP_INIT_ROOT_USER_PW -H ldap://localhost -f memberof3.ldif
