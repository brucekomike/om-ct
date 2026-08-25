# weblate
## 初始化
由 `gen-env.sh` 生成 `weblate.yaml`，站点地址为 `weblate.$MURL`。

管理员账号与邮箱在 `templates/.env.weblate` 中配置：

- `WEBLATE_ADMIN_NAME` / `WEBLATE_ADMIN_EMAIL` / `WEBLATE_ADMIN_PASSWORD`
- `WEBLATE_SITE_DOMAIN`（即 `WEBLATEURL`）

完整配置项参考 [Weblate 官方文档](https://docs.weblate.org/en/latest/admin/install/docker.html#generic-settings)。
