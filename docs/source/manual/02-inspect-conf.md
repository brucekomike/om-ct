# 查看 conf

`conf/` 目录存放各服务的配置模板，按「模板 + 环境变量」的方式生成实际配置：

- **`conf/nginx-templates-ssl/`**：与 certbot 集成、自动签发证书的 nginx 模板（推荐），包含 `.env.template` 与各站点 `<site>.conf` 模板，`copy.sh` 会把模板渲染到 `conf/nginx/`。
- **`conf/nginx-templates/`**：不带证书管理的普通版 nginx 模板。
- **`conf/frp-templates/`**：frp 的 `frpc.toml`、`frps.toml` 及 `conf.d/` 模板，`copy.sh` 渲染到 `conf/frp/`，依赖 nginx 的 `.env`。
- **`conf/ldap/`**：OpenLDAP 的 bootstrap ldif 等，`copy.sh` 复制 `bootstrap-template.ldif` 为 `bootstrap.ldif`。
- **`conf/docs/`**：文档站点的配置列表生成脚本。

各目录下生成的配置位于对应的无后缀目录（如 `conf/nginx/`、`conf/frp/`），已存在的文件不会被覆盖。
