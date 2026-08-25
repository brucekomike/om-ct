# nextcloud
## 安装应用
需要先临时启动 `za-nextcloud.yaml`，再通过 shell 安装应用：

```shell
docker compose -f za-nextcloud.yaml up
```
```shell
docker compose -f za-nextcloud.yaml exec -u www-data cloud bash
```
```shell
php occ config:system:set proxy --value "http://127.0.0.1:7890"
```
```shell
php occ app:install <package name>
```

期间可以顺手给 nextcloud 配置 proxy。
