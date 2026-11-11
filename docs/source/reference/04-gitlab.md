# GitLab Omnibus

Compose runs the official GitLab CE Omnibus image behind the shared Nginx reverse proxy. Nginx terminates HTTPS and forwards requests over the `front_tier` Docker network to `http://gitlab:80`; GitLab's `external_url` remains HTTPS so generated links and clone URLs use the public URL.

## Setup

1. Set `GITLABURL` in the selected SSL or FRP Nginx `.env` file (default: `gitlab.$MURL`).
2. Add `gitlab.conf` to `nginx_config_list`, then regenerate the Nginx site files.
3. Run `gen-env.sh` from `compose/`, then start the stack with `docker compose up -d`.

GitLab data is stored under the `GITLAB_HOME` path in `.env.gitlab` (default `/opt/gitlab`). The Nginx and GitLab services communicate over `front_tier`; GitLab trusts Docker's private `172.16.0.0/12` address range for forwarded client IPs. A LAN subnet such as `192.168.0.0/24` is not used for this in-Compose proxy connection.

SMTP is disabled by default. Configure it separately in `GITLAB_OMNIBUS_CONFIG` if outgoing mail is needed.
