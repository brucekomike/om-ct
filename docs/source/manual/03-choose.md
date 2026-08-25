# 选择你要的服务

两处决定最终启用哪些服务：

1. **nginx 站点**：编辑 `conf/nginx-templates-ssl/.env`（或 `conf/nginx-templates/.env`）：

   ```bash
   MURL="example.com"
   nginx_config_list=(
       "wiki.conf"
       "cloud.conf"
       "gitlab.conf"
       # "dev-ct.conf"
   )
   nginx_doc_list=(
       "docs"
   )
   ```

   只有列在 `nginx_config_list` 里的站点会生成对应的 nginx 配置；`nginx_doc_list` 用于文档站点，URL 为 `<docname>.$MURL`。

2. **compose 服务**：编辑 `compose.yaml` 的 `include` 列表，把不需要的服务注释掉。

两个列表保持一致：启用了 compose 服务就要有对应的 nginx 站点（反向代理场景下），反之亦然。
