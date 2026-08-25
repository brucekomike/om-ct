# keycloak
## 初始化
由 `gen-env.sh` 生成 `keycloak.yaml`，站点地址为 `auth.$MURL`（`KEYCLOAKURL`），数据库为 postgres。

- 管理员账号在 `templates/.env.keycloak` 中配置：`KC_BOOTSTRAP_ADMIN_USERNAME` / `KC_BOOTSTRAP_ADMIN_PASSWORD`。
- 独立开发变体：`zb-keycloak.yaml`（`start-dev` 模式，直接暴露 8080 端口，并自带 openldap）。
