# Backslash

[Backslash](https://github.com/Manan-Santoki/Backslash) is a self-hosted LaTeX editor with live PDF preview. `gen-env.sh` generates its Compose file and application environment file. Its web app, WebSocket server, PostgreSQL database, Redis queue, and dedicated compiler worker run as part of this stack; project files and database state persist in Docker volumes.

## Setup

1. Set `BACKSLASHURL` in the selected SSL or FRP nginx `.env` file (default: `backslash.$MURL`).
2. Add `backslash.conf` to `nginx_config_list` in that file, then regenerate nginx sites.
3. Enable the `backslash.yaml` include in `compose.yaml` and run `docker compose up -d` from the `compose` directory. The first start builds the app and the TeX Live compiler image and may take several minutes.
4. Visit `https://$BACKSLASHURL` and create an account.

The Compose template builds directly from the upstream Backslash `master` branch. The generated `.env.backslash` sets the public URL, HTTPS cookies, WebSocket proxy path, and a generated session secret. Change `POSTGRES_PASSWORD` and the matching password in `DATABASE_URL` in that file before deployment. For password-reset email, configure the SMTP values there.

The app and compile worker require access to `/var/run/docker.sock` to launch sandboxed TeX Live compiler containers. Project data is stored in the `backslash-project-data` volume; keep it when updating or recreating the stack.
