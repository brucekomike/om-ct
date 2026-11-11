# Casdoor

`gen-env.sh` generates `casdoor.yaml` and `.env.casdoor`. The Compose service runs Casdoor with PostgreSQL; the local default URL is `http://casdoor.localhost:8000`.

The generated environment file contains a random database password. For local testing, the initial `built-in/admin` password defaults to `local-admin-password`. For a public deployment, change that password and set `origin` to the public HTTPS URL. The direct local port does not require nginx or TLS.

Configure Casdoor's public origin to match `CASDOORURL` when changing the default URL. Register OIDC clients in Casdoor with the callback URL documented in [OAuth2 Proxy](12-oauth2-proxy.md).
