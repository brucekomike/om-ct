# openldap
## 初始化
由 `gen-env.sh` 生成 `openldap.yaml`，用于 keycloak 的 unified-login。

- 初始化数据来自 `conf/ldap/`：运行 `copy.sh` 后，手动修改 `bootstrap.ldif` 中的域名等信息。
- 初始化参数在 `templates/.env.openldap` 中，例如 `LDAP_INIT_ORG_DN` / `LDAP_INIT_ORG_NAME`，需要手动改成真实值。
