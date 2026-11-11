# OAuth2 Proxy

`gen-env.sh` generates `oauth2-proxy.yaml` and `.env.oauth2-proxy`. Local defaults use Casdoor as the OIDC provider at `http://casdoor.localhost:8000` and the callback at `http://oauth2.localhost:4180/oauth2/callback`. OAuth2 Proxy serves RustPad as its upstream, while the nginx site can also use its auth-request endpoint.

## Setup

1. Start Casdoor and visit `http://casdoor.localhost:8000` to sign in as `built-in/admin`. The default local password is `local-admin-password`.
2. Create a Casdoor OIDC application with client ID `rustpad-local`, client secret `local-only-client-secret`, and redirect URL `http://oauth2.localhost:4180/oauth2/callback`.
3. Start RustPad, Casdoor, and OAuth2 Proxy with Compose, then visit `http://oauth2.localhost:4180`.

For a public deployment, replace the localhost hostnames, local client secret and admin password; use the public HTTPS URLs and enable secure cookies.

## Local Docker testing

The standard service templates default to localhost URLs. From the repository root, create the nginx environment file if it does not exist, then generate the Compose service files:

```sh
cp conf/nginx-templates-ssl/.env.template conf/nginx-templates-ssl/.env
cd compose
./gen-env.sh
```

Test RustPad directly, without the authentication services:

```sh
docker compose up -d rustpad
```

Open `http://localhost:3030`.

Test Casdoor by itself (plus its database):

```sh
docker compose up -d casdoor_db casdoor
```

Open `http://casdoor.localhost:8000`. Its OIDC discovery document is at `http://casdoor.localhost:8000/.well-known/openid-configuration`.

After creating the OIDC application described above, test the complete login path:

```sh
docker compose up -d casdoor_db casdoor rustpad oauth2-proxy
```

Visit `http://oauth2.localhost:4180`; after Casdoor sign-in, OAuth2 Proxy should return you to RustPad. The published service ports are bound to `127.0.0.1`. To stop the services, run `docker compose stop casdoor_db casdoor rustpad oauth2-proxy`.
