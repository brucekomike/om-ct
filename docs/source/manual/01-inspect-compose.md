# 查看 compose

`compose/` 目录包含所有 docker compose 相关文件：

- **`compose.yaml`**：主入口，通过 `include` 列表引入各服务的 compose 文件，按需注释即可启用/停用服务。
- **`templates/zz-*.yaml`**：各服务的 compose 模板，变量由环境变量插值。
- **`templates/.env.*.template`**：各服务的环境变量模板，其中的 `$(generate_token)` 会在生成时填入随机值。
- **`gen-env.sh`**：生成脚本，读取 `../conf/nginx-templates-ssl/.env`，把上述模板渲染为 `compose/` 下的 `*.yaml` 与 `templates/.env.*`。已存在的文件不会被覆盖，可重复运行：

  ```bash
  cd compose
  ./gen-env.sh
  ```

- **`.env.*`**：各服务实际使用的环境变量文件，需要手动检查调整，常见的必填项：
  - `.env.nginx`：`CERTBOT_EMAIL`（证书申请）、`CERTBOT_ENABLED` / `STAGING`（建议先用 `STAGING=1` 测试）。
  - `.env.openldap`：`LDAP_INIT_ORG_DN`、`LDAP_INIT_ORG_NAME` 等组织信息（`gen-env.sh` 运行时也会提示这一点）。
  - `.env.nextcloud`：SMTP 相关配置（`SMTP_HOST`、`SMTP_PORT`、`SMTP_NAME` 等）。
  - `.env.weblate`：管理员账号与邮箱（`WEBLATE_ADMIN_NAME`、`WEBLATE_ADMIN_EMAIL` 等）。
  - 各文件的 `http(s)_proxy` / `HTTP(S)_PROXY`：按需填写。

如需在多个文件间保持相同的随机密码，请手动同步。
