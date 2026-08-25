# 使用 frp 代理

frp 把位于 NAT 之后的服务器对外暴露：

- **frp-server**（`frp-server.yaml`）：跑在公网服务器上，监听 `12048` 端口，并通过 vhost 把 80/443 转发到代理。
- **frp-client**（`frp-client.yaml`）：跑在每台 NAT 后的主机上，把本地服务（如 nginx 的 80/443）隧道到 server。

使用前：

1. 两边使用相同的认证 token（`AUTH_TOKEN` / `GENERATED_TOKEN`）。
2. 编辑 `conf/frp/conf.d/frpc.toml` 添加或调整代理；注意 `name` 必须在所有 client 之间唯一，否则配置会被覆盖。
3. `conf/frp-templates` 里生成的 `customDomains` 来自 nginx 的 `nginx_config_list`，所以要先在 {doc}`03-choose` 里启用对应站点。

模板中已包含 `http`/`https`（走 nginx）和 `ssh`（tcp，远程 port `22222`）三类代理。
