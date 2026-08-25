# gitlab
## 初始化
由 `gen-env.sh` 生成 `gitlab.yaml`，站点地址为 `gitlab.$MURL`。

## SMTP
SMTP 相关配置写在 `gitlab.yaml` 的 `GITLAB_OMNIBUS_CONFIG` 中，默认为空，按需填写：

- `smtp_address` / `smtp_port`
- `smtp_user_name` / `smtp_password`
- `smtp_domain` / `gitlab_email_from` 等
