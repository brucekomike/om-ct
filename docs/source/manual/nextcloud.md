# nextcloud
## how to add apps
you have to temporary boot up the za-nextcloud.yaml, then use shell to install apps.

- meaning while, you can setup proxy for nextcloud
```shell
docker compose -f za-nextcloud.yaml up
```
```shell
docker compose -f za-nextcloud yaml exec -u www-data cloud bash
```
```shell
php occ config:system:set proxy --value "http://127.0.0.1:7890"
```
```shell
php occ app:install <package name>
```