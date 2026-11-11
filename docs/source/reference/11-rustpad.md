# RustPad

`gen-env.sh` generates `rustpad.yaml`. RustPad is directly available at `http://localhost:3030` for local testing. It uses a persistent SQLite volume and retains inactive documents for 30 days by default.

The supplied nginx site configuration supports RustPad's WebSocket connection and protects the site with OAuth2 Proxy. Enable `rustpad.conf`, `oauth2-proxy.conf`, and `casdoor.conf` together in the selected SSL or FRP nginx template list, and enable their three Compose services in `compose.yaml`.
