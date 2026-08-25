# 配置 nginx

nginx 配置采用「模板 + 环境变量」的方式生成，有两个变体：

- `conf/nginx-templates-ssl/`：与 certbot 集成、自动签发证书的版本（推荐）
- `conf/nginx-templates/`：不带证书管理的普通版

步骤：

1. 以模板为基础创建 `.env`：

   ```bash
   cd conf/nginx-templates-ssl
   cp .env.template .env
   ```

2. 编辑 `.env`，填写主域名 `MURL`，并取消注释要启用的站点（`nginx_config_list` / `nginx_doc_list`）。

3. 运行 `copy.sh`，将模板渲染到 `conf/nginx/`：

   ```bash
   ./copy.sh
   ```

   脚本会读取当前目录下的 `.env`，把模板里的变量替换后写入 `../nginx/<conf>.conf`。已存在的文件不会被覆盖。
