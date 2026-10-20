# inception

![Docker](https://img.shields.io/badge/Docker-Compose%20v2-2496ED?logo=docker&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey)

**A three-tier WordPress infrastructure deployed with Docker Compose.** NGINX
terminates TLS and proxies PHP requests to a WordPress/PHP-FPM container, which
talks to MariaDB over a private bridge network. Each service is built from its
own minimal Debian image — no stock nginx/wordpress/mariadb images — with the
bootstrap logic in hand-written entrypoints.

*Infrastructure as code · Docker · TLS · networking · persistence · Linux*

## Highlights

- **One Dockerfile per service** — NGINX, WordPress/PHP-FPM 8.2 and MariaDB are
  each built `FROM debian:bookworm` and configured by their own entrypoint.
- **TLS by default** — a 2048-bit self-signed certificate is generated on first
  boot; only TLS 1.2/1.3 are enabled and only port 443 is published.
- **Isolated network** — services run on a custom bridge and reach each other by
  DNS name (`wordpress:9000`, `mariadb:3306`); no other port is exposed.
- **Persistent data** — named volumes are bind-mounted to
  `/home/yassabda/data/{wordpress,mariadb}`, surviving container removal and
  rebuilds.
- **Idempotent bootstrap** — a `.initialized` flag in MariaDB and a
  `wp-config.php` guard in WordPress make restarts safe.
- **Hardened database init** — root password set, anonymous users removed and
  test database dropped before the service starts.

## Architecture

```text
browser ──HTTPS:443──▶ nginx (TLS, config rendered from template)
                         │ fastcgi :9000
                         ▼
                     wordpress (PHP-FPM 8.2, wp-cli)
                         │ mysql :3306
                         ▼
                     mariadb
       volumes: wordpress_data / mariadb_data → /home/yassabda/data/...
       network: inception-network (bridge, internal DNS)
```

## Quick start

```console
$ git clone git@github.com:imyassmine/inception.git && cd inception
$ cp srcs/.env.example srcs/.env      # then fill in the 4 password variables
$ echo "127.0.0.1 yassabda.42.fr" | sudo tee -a /etc/hosts
$ make                                # build images and start the stack
```

Open **https://yassabda.42.fr** and accept the self-signed certificate (or run
`curl -k https://yassabda.42.fr`). Requirements: a Linux host or VM with Docker
Engine and Compose v2; `sudo` is only needed for the hosts entry and cleanup.

## Configuration

[`srcs/.env.example`](srcs/.env.example) holds the non-sensitive defaults —
domain, data directory, database name and user, WordPress titles and users.
Copy it to `srcs/.env` and fill the four secrets (`MYSQL_PASSWORD`,
`MYSQL_ROOT_PASSWORD`, `WP_ADMIN_PASSWORD`, `WP_USER_PASSWORD`); the resulting
file is git-ignored.

## Operations

| Command | Action |
| --- | --- |
| `make` | Build images and start the stack |
| `make status` / `make logs` | Container status / follow all logs |
| `make check` | Validate the compose file |
| `make down` | Stop and remove containers and network |
| `make clean` | Also remove the built images |
| `make fclean` | `clean` + volumes and the host data directory (destructive) |
| `make re` | Full rebuild from scratch |
| `make help` | List every target |

Sanity checks: `make status` shows three containers `Up`, `make logs` shows no
bootstrap errors, `curl -k https://yassabda.42.fr` returns the WordPress HTML
over TLS, and `make check` validates the compose file.

## Under the hood

- `srcs/requirements/nginx/` — Debian image with NGINX and OpenSSL; the
  entrypoint generates the certificate, renders `nginx.conf` from a template
  with `envsubst`, validates it (`nginx -t`) then runs NGINX in the foreground.
- `srcs/requirements/wordpress/` — PHP-FPM image with `wp-cli`; waits for
  MariaDB, downloads WordPress, writes `wp-config.php`, installs the site and an
  editor user, then runs `php-fpm -F`.
- `srcs/requirements/mariadb/` — MariaDB image whose entrypoint initialises the
  data directory, creates the database and user from the environment, sets the
  root password, then `exec`s `mysqld`.
- `srcs/docker-compose.yml` — three services with `restart: unless-stopped`,
  `depends_on` ordering and a shared `wordpress_data` volume (read-only in
  NGINX); every service receives the domain and credentials from `.env`.

## Scope

Single-host academic infrastructure project: self-signed TLS (no ACME), secrets
passed through an env file rather than Docker secrets or a vault, and no
healthchecks or automated test suite in the repository.

---

42 Paris curriculum project · solo · Yassmine Abdallah ([@imyassmine](https://github.com/imyassmine))
