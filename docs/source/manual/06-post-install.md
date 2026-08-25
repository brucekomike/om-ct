# 需要安装后配置的应用

## mediawiki

`gen-env.sh` 执行后，`mediawiki.yaml` / `mediawiki-fpm.yaml` 会被生成：

- 把自己的 `LocalSettings.php` 放到 `conf/wiki/LocalSettings.php`；
- 在 compose 文件中取消 `LocalSettings.php` 挂载行的注释。

首次访问站点时按向导完成安装。
