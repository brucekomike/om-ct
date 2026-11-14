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

## 用 Casdoor 做 OIDC 登录

下面这套是在本机（localhost）跑通并验证过的配置：Nextcloud 用
`user_oidc` 应用把登录交给 Casdoor。所有步骤都在 `compose/` 目录内执行，
只监听回环地址，不对外网开放。

文中的 `<CLIENT_SECRET>` 等尖括号内容都是占位符，请自己生成，不要照抄。

### 用哪个 Casdoor

`gen-env.sh` 生成的 `casdoor.yaml` 跑在 `127.0.0.1:8000`，其
`origin` 就是 `http://casdoor.localhost:8000`，所以 discovery 文档里的
`issuer`、`authorization_endpoint`、`token_endpoint` 全部是该地址。
Nextcloud 直接用它即可，不需要改 Casdoor 容器的配置。

```shell
curl -s http://127.0.0.1:8000/.well-known/openid-configuration | python3 -m json.tool | head
```

### 启动 Nextcloud

`nextcloud.yaml` 只含 php-fpm 与数据库，没有前端；`za-nextcloud.yaml` 的
nginx 监听 80，会和本机已有的 nginx 冲突；`conf/nginx-templates/cloud.conf`
又带着 certbot 写入的 443 与强制 https 跳转（`ssl_certificate` 指向
`/etc/letsencrypt/live/<主机名>/fullchain.pem`），在没有证书时
`nginx -t` 直接返回 1。因此这里用独立的 dev/test 变体
`zc-nextcloud-oidc.yaml`：固定 compose 项目名、监听
`127.0.0.1:${NC_OIDC_PORT}`（默认 8880）、不带 `container_name`，
配套的前端配置由 `nginx-oidc-cloud.conf` 生成。

```shell
cp conf/nginx-templates-ssl/.env.template conf/nginx-templates-ssl/.env
cd compose
./gen-env.sh
docker compose -f zc-nextcloud-oidc.yaml up -d
```

打开 `http://cloud.localhost:8880`。

`zc-nextcloud-oidc.yaml` 里 `cloud` 与 `nginx` 使用
`network_mode: "host"`，这不是偷懒而是必须，原因见下面「本地 HTTP 下的两个开关」。

### 完成安装

`.env.nextcloud` 只给了数据库变量，没有 `NEXTCLOUD_ADMIN_USER` /
`NEXTCLOUD_ADMIN_PASSWORD`。镜像因此只初始化目录，不做安装，
`status.php` 会一直是 `"installed": false`，等着网页安装向导。
命令行下用 `occ` 收尾即可，数据库账号直接用容器里已有的环境变量，
不要把密码写进命令行：

```shell
docker compose -f zc-nextcloud-oidc.yaml exec -T -u www-data cloud bash
```
```shell
php occ maintenance:install \
  --database mysql --database-host "$MYSQL_HOST" \
  --database-name "$MYSQL_DATABASE" --database-user "$MYSQL_USER" \
  --database-pass "$MYSQL_PASSWORD" \
  --admin-user <本地管理员> --admin-pass <本地管理员密码> \
  --data-dir /var/www/html/data
```

镜像的 `NEXTCLOUD_TRUSTED_DOMAINS` 只在镜像自己执行安装那一步才写入
`config.php`；改用 `occ` 安装时它会被静默忽略，`trusted_domains` 里只剩
`localhost`，用 `cloud.localhost` 访问会得到 `{"error": "Trusted domain error.", "code": 15}`。
需要补上：

```shell
php occ config:system:set trusted_domains 1 --value=cloud.localhost
php occ config:system:set overwrite.cli.url --value=http://cloud.localhost:8880
```

另外，`config.php` 的 `dbhost` 在安装时就定死了。若之后改动拓扑（例如数据库
换端口），`occ` 会因为连不上库而整体报错，得先改 `config.php`。
`zc-nextcloud-oidc.yaml` 用 `extra_hosts` 把服务名 `cloud_db` 指到
`127.0.0.1`，并让数据库只在回环发布 3306，这样 `dbhost => cloud_db` 一直可用，
和 `za-nextcloud.yaml` 的思路一致。

### 装 user_oidc

需要应用商店可达，所以要配 proxy。注意 `.env.nextcloud` 生成的代理地址是
`http://$HOSTNAME:7890`，即**生成那台机器的主机名**，容器里解析不到；
在 host 网络下按本页前面的写法用 `127.0.0.1:7890` 即可。

```shell
php occ config:system:set proxy --value "http://127.0.0.1:7890"
php occ app:install user_oidc
```

本次实测装的是 `user_oidc 8.13.0`，Nextcloud `32.0.5`。

### 在 Casdoor 注册应用

**不要用 `built-in` 组织。** Casdoor 拒绝往里加普通用户，报
`adding a new user to the 'built-in' organization is currently disabled`，
因为该组织里的用户默认是全局管理员。新建一个专用组织，把应用指向它。

注册时这几个字段最关键：

| 字段 | 值 | 说明 |
| --- | --- | --- |
| `organization` | 新建的组织名 | 决定能登录哪些用户 |
| `clientId` | 例如 `nextcloud-oidc-local` | 会出现在令牌的 `aud` 里 |
| `clientSecret` | 由 Casdoor 生成 | 别写进仓库，文档只放占位符 |
| `redirectUris` | `http://cloud.localhost:8880/apps/user_oidc/code` | 必须逐字符相等 |
| `cert` | `cert-built-in` | 签发 JWT 的密钥 |
| `tokenFormat` | `JWT` | |

`redirectUris` 是精确匹配，端口或 http/https 差一点就会被拒。
`user_oidc` 生成的回调地址就是「站点根地址 + `/apps/user_oidc/code`」，
所以 Nextcloud 换了端口或协议，这里必须同步改。

### 配置 provider

`user_oidc` 支持从文件读密钥，用 `--clientsecret-file`，别让密钥出现在命令行或
进程列表里：

```shell
docker compose -f zc-nextcloud-oidc.yaml cp <密钥文件> cloud:/tmp/client-secret
docker compose -f zc-nextcloud-oidc.yaml exec -T cloud chown www-data:www-data /tmp/client-secret
docker compose -f zc-nextcloud-oidc.yaml exec -T -u www-data cloud bash
```
```shell
php occ user_oidc:provider "Casdoor local" \
  --clientid=nextcloud-oidc-local \
  --clientsecret-file=/tmp/client-secret \
  --discoveryuri=http://casdoor.localhost:8000/.well-known/openid-configuration \
  --scope="openid profile email" \
  --unique-uid=1 \
  --use-private-key-jwt=0
rm -f /tmp/client-secret
```

还要开两个开关，否则点击登录只会看到报错：

```shell
php occ config:app:set user_oidc allow_insecure_http --value=1
php occ config:system:set allow_local_remote_servers --value=true --type=boolean
```

`user_oidc:provider` 列表里的 End session endpoint 一栏是空的：discovery 文档虽然
广播了 `end_session_endpoint`（`/api/logout`），但该命令行只认
`--endsessionendpointuri`，需要统一登出时要显式传入。

### 本地 HTTP 下的两个开关

这不是可有可无的加固，而是本机纯 HTTP 环境能否跑通的前提。

1. `allow_insecure_http`。`user_oidc` 默认要求 HTTPS，判定在
   `LoginController::isSecure()`，三个条件满足其一即可：调试模式、
   `allow_insecure_http`、`getServerProtocol() === 'https'`。
   没开时报 `You must access Nextcloud with HTTPS to use OpenID Connect.`
   生产环境请认真用 TLS，不要用这个开关。
2. `allow_local_remote_servers`。Nextcloud 的 SSRF 防护会拒绝连本地地址，
   日志里是 `Host "casdoor.localhost" violates local access rules`
   （`OCP\Http\Client\LocalServerException`）。同一条日志里还实测到
   cURL 的 RFC 6761 行为：**cURL 把 `*.localhost` 一律当回环地址**，
   无视 DNS。桥接网络里的容器因此永远连不上只在宿主机回环发布的 Casdoor，
   即使 `getent` 和 PHP 的 `getaddrinfo` 都能解析到容器地址：

   ```text
   * Trying [::1]:8000... Connection refused
   * Trying 127.0.0.1:8000... Connection refused
   ```

   这就是 `cloud` 必须走 host 网络的原因：在 host 网络下回环就是宿主机的回环，
   发布在 `127.0.0.1:8000` 的 Casdoor 才连得上。这也解释了
   `za-nextcloud.yaml` 为什么同样用 host 网络。
   开了这个开关等于允许 Nextcloud 访问内网地址，只适合本地测试。

### Casdoor 令牌的实测行为

以下几条都是从本机 `127.0.0.1:8000` 真实签发的令牌里读出来的，
不是推测。核对第三方时请特别注意前两条，它们容易让校验逻辑「看起来通过、
实际放宽」。

- `aud` 是**数组**，内容是 `clientId`，不是标量，也不是应用名：

  ```json
  "aud": ["nextcloud-oidc-local"]
  ```

- `sub` 就是 Casdoor 的 `user.Id`，而 `Id` 有两种形态。
  带显式 `Id` 建出来的行保留 `<组织>/<用户名>`；不传 `Id` 时由 `AddUser`
  生成 UUID（自助注册走的就是这条路）。本机两个用户实测：

  | 建用户方式 | `sub` |
  | --- | --- |
  | 指定 `Id` | `nextcloud/ncseeded` |
  | 不指定 `Id` | `f9b5f765-6c7b-48d2-b96f-eccc9a3483ec` |

  改用户名**不会**改 `Id`：把 `ncseeded` 改名成 `ncseeded-renamed` 之后，
  `Id` 仍是 `nextcloud/ncseeded`，令牌里的 `sub` 也没变，
  但 `name` 跟着变了。所以拿 `sub` 当关联键是稳的，
  拿 `name`/`preferred_username` 当键则会在改名后丢账号。
  顺带一个坑：Casdoor 的 API 用 `owner/name` 定位用户，改名后用旧名字查
  `/api/get-user` 会返回 `status: ok` 而 `data` 是 `null`——不报错，只是查不到。

- `--unique-uid=1` 时，Nextcloud 内部 UID 是 64 位十六进制散列，
  与 `sub` 的对应关系存在 `oc_user_oidc(user_id, display_name, provider_id, sub)`：

  | display_name | sub |
  | --- | --- |
  | ncseeded | `nextcloud/ncseeded` |
  | ncsignup | `f9b5f765-6c7b-48d2-b96f-eccc9a3483ec` |

- 令牌把整个用户对象塞进了声明。口令相关字段是**键在值空**（实测
  `password`、`passwordSalt`、`hash`、`preHash`、`totpSecret` 为空串，
  `recoveryCodes` 为 `null`），所以并没有泄露口令材料；但
  `lastSigninIp`、`registerSource`、`passwordType` 是有值的，
  而 JWT 只签名不加密，任何拿到令牌的一方都能读。给外部应用发令牌前，
  应该用应用的 `tokenFields` 收窄。
- `roles` 与 `groups` 默认是空数组；`isAdmin` 是布尔。
  本次没能造出非空的 `roles`（全局组织和组织内两种角色都试过，令牌里仍是 `[]`），
  所以「roles 是对象数组而非字符串数组」这一点本轮未复现，
  接入前请用自己环境里真实的角色数据再验一次。
- `nbf`、`auth_time`、`iat`、`exp` 都在。校验方时钟落后于 Casdoor 会直接判定
  令牌无效。
- `iss` 由 Casdoor 的 `origin` 决定。`origin` 与外部实际访问地址不一致时，
  依赖 `iss` 的校验会失败。

### 验证

`/login/oauth/authorize` 在这台 Casdoor 上是**前端 SPA 路由**：即使带着有效会话，
它也只返回 `index.html`，授权码由页面里的脚本再发起请求换取。
也就是说，只用 curl 走不通授权这一步，得用真浏览器。
`token_endpoint`（`/api/login/oauth/access_token`）本身是普通表单接口，可以直接调。

链路上要确认的四件事，以及各自的证据：

1. discovery 文档取到了：`issuer` 与端点齐全。
2. 授权跳转正确：浏览器会停在
   `http://casdoor.localhost:8000/login/oauth/authorize?...`，
   带 `client_id`、`response_type=code`、`scope`、`redirect_uri`、
   `state`、`nonce`，以及 PKCE 的 `code_challenge` 和
   `code_challenge_method=S256`。
3. 换到令牌：`user_oidc` 后台用授权码 + `code_verifier` 换取，
   失败会停在 `Could not reach the OpenID Connect provider.`
   或 `Invalid state param.`。
4. 会话真的建立：登录后停在 `/apps/dashboard/`，
   且带该会话调用 OCS 能拿回自己的账号：

   ```shell
   curl -s -b <会话 cookie 文件> -H 'OCS-APIRequest: true' \
     http://cloud.localhost:8880/ocs/v2.php/cloud/user?format=json
   ```

   本次实测返回的 `id` 就是 `oc_user_oidc` 里那条散列 UID。

### 排查

| 现象 | 原因 |
| --- | --- |
| `Trusted domain error.` (15) | `trusted_domains` 没加访问域名；`NEXTCLOUD_TRUSTED_DOMAINS` 在非镜像安装时不生效 |
| `installed: false` | 缺 `NEXTCLOUD_ADMIN_*`，镜像只初始化不安装 |
| `You must access Nextcloud with HTTPS to use OpenID Connect.` | 纯 HTTP 下没开 `allow_insecure_http` |
| `Could not reach the OpenID Connect provider.` | `allow_local_remote_servers` 没开，或容器无法解析/连接 `casdoor.localhost` |
| 日志 `cURL error 7` 连不上 `casdoor.localhost` | cURL 把 `*.localhost` 当回环；桥接网络容器连不到宿主机回环发布的端口，需要 host 网络 |
| 日志 `Failed to connect ... getaddrinfo for cloud_db failed` | `config.php` 的 `dbhost` 与当前拓扑不符，用 `extra_hosts` 或改配置 |
| Casdoor 报 `adding a new user to the 'built-in' organization is currently disabled` | 换专用组织，或给 `built-in` 开 `hasPrivilegeConsent`（不推荐） |
| 授权页一直回登录表单 | `redirectUris` 与回调不完全一致，或应用指向的组织里没有该用户 |
