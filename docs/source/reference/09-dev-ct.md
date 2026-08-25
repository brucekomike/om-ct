# dev-ct
## 初始化
由 `gen-env.sh` 生成 `dev-ct.yaml`，是一个独立的开发环境容器，站点地址为 `dev.$MURL`（`DEVCTURL`）。

- 工作区挂载自 `conf/dev-ct/`。
- Web UI 端口映射为 `9001:8080`。
