# 配置 frp（可选）

frp 用于把位于 NAT 之后的服务器对外暴露，仅在需要时配置。

frp 配置同样由模板生成，依赖 nginx 的 `.env`：

```bash
cd conf/frp-templates
./copy.sh
```

脚本会优先加载 `conf/nginx-templates/.env`，找不到时回退到 `conf/nginx-templates-ssl/.env`，然后把 `frpc.toml`、`frps.toml` 和 `conf.d/frpc.toml` 渲染到 `conf/frp/`。
