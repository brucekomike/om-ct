# 使用 mediawiki

- 站点地址为 `wiki.$MURL`（见 `wiki.conf`）。
- 两种变体：
  - `mediawiki.yaml`：内置 apache。
  - `mediawiki-fpm.yaml`：fpm 版本（推荐），需要搭配 `nginx` 反向代理。
- 数据库（MariaDB）数据与备份分别保存在 `wiki_db_data` / `wiki_db_backups` 卷。
- 自定义配置见 {doc}`06-post-install`（`conf/wiki/LocalSettings.php`）。
