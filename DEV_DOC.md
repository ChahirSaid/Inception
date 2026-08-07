*This project has been created as part of the 42 curriculum by schahir.*

# Developer Documentation

This document describes how to set up, build, and work on the Inception project from a developer's perspective.

## 1. Setting up the environment from scratch

### Prerequisites
- A Linux virtual machine (the project subject requires this to be done in a VM, not directly on the host).
- `docker` and the `docker compose` plugin installed and working (`docker compose version` should succeed).
- `make`.
- sudo/root access, needed for editing `/etc/hosts` and for `make fclean` to remove the host data directory.

### Repository layout
```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs
    ├── docker-compose.yml
    ├── .env                     # environment variables (git-ignored)
    └── requirements
        ├── mariadb/
        │   ├── Dockerfile
        │   └── conf/ ...
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/ ...
        ├── wordpress/
        │   ├── Dockerfile
        │   └── conf/ ...
        └── bonus/
            ├── redis/
            ├── ftp/
            ├── adminer/
            ├── website/
            └── portainer/
```

Each service directory under `requirements/` contains its own `Dockerfile` and any configuration files / entrypoint scripts it needs, following the "one Dockerfile per service, no pre-built images" rule of the subject.

### Configuration files and secrets

All configuration lives in `srcs/.env`, loaded by every service via `env_file: - .env` in `docker-compose.yml`. It defines:

- `MARIA_DB_NAME`, `USER`, `USER_PASSWORD`, `ROOT_PASSWORD` — MariaDB configuration.
- `WORDPRESS_DB_HOST` — hostname MariaDB is reachable at from WordPress (the `wordpress` service, resolved via Docker's internal DNS on the `inception` network).
- `DOMAIN_NAME` — the domain the site is served under (`schahir.42.fr`).
- `WP_ADMIN_USER`, `WP_ADMIN_EMAIL`, `WP_ADMIN_PASSWORD` — WordPress administrator account.
- `WP_USER`, `WP_USER_EMAIL`, `WP_USER_PASSWORD` — a secondary, non-admin WordPress user.
- `FTP_USER`, `FTP_PASSWORD` — credentials for the bonus FTP service.

`.env` must never be committed — it is git-ignored. No credential is hardcoded in any Dockerfile; every Dockerfile/entrypoint reads its secrets from the environment at container start.

Before your first run, add the domain to your local DNS resolution:
```bash
echo "127.0.0.1   schahir.42.fr" | sudo tee -a /etc/hosts
```

## 2. Building and launching the project

The `Makefile` at the repository root wraps `docker compose`, always pointing at `srcs/docker-compose.yml` and `srcs/.env`:

```make
COMPOSE = docker compose \
        -f srcs/docker-compose.yml \
        --env-file srcs/.env
```

**Build and start every service** (creates the host data directories first, then builds and starts all containers in detached mode):
```bash
make
```
This runs, in effect:
```bash
mkdir -p /home/schahir/data/mariadb
mkdir -p /home/schahir/data/wordpress
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build
```

**Stop containers, keep data:**
```bash
make down
```

**Stop containers and delete volumes:**
```bash
make clean
```

**Full teardown** (containers, volumes, all local images, and the host data directory):
```bash
make fclean
```

**Rebuild from scratch:**
```bash
make re
```

When iterating on a single service's Dockerfile, you can rebuild and restart just that service without tearing down everything else:
```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build <service_name>
```

## 3. Managing containers and volumes

**Useful Docker Compose commands** (run from the repo root, or `cd srcs` first):
```bash
docker compose -f srcs/docker-compose.yml ps            # list running services
docker compose -f srcs/docker-compose.yml logs -f nginx # follow logs for one service
docker compose -f srcs/docker-compose.yml exec wordpress sh   # shell into a running container
docker compose -f srcs/docker-compose.yml restart mariadb     # restart a single service
```

**Useful raw Docker commands:**
```bash
docker ps -a                 # all containers, including stopped ones
docker images                # list built images
docker volume ls             # list volumes (mariadb_data, wordpress_data, etc.)
docker network ls            # confirm the inception network exists
docker system df             # disk usage summary
```

All services are configured with `restart: always`, so a crashed container will be restarted automatically by the Docker daemon; you generally don't need to restart them by hand.

## 4. Where project data is stored and how it persists

Two named volumes are declared in `docker-compose.yml`:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/schahir/data/mariadb
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/schahir/data/wordpress
```

- `mariadb_data` is mounted into the `mariadb` container at `/var/lib/mysql` — this is where all database files (WordPress tables, users, posts, etc.) live.
- `wordpress_data` is mounted at `/var/www/html` in both the `wordpress`, `nginx`, and `ftp` containers — this is the WordPress installation and uploaded media, shared between the app server (for writing/serving PHP) and NGINX (for serving static assets) and FTP (for direct file access).

Even though these are declared as Docker **named volumes** (not raw bind mounts) in the Compose syntax — which the subject requires — their storage backend is pinned to specific paths on the host (`/home/schahir/data/mariadb` and `/home/schahir/data/wordpress`) via `driver_opts`. This means:
- Data survives `docker compose down` and container recreation.
- Data is only removed by `docker compose down -v` (or `make clean` / `make fclean`, which use `-v`), or by manually deleting the host directory.
- You can inspect the raw files directly on the host in `/home/schahir/data/` while the stack is stopped (or even while running, though writes should go through the containers to avoid permission/lock issues).

To reset the project to a completely fresh state (empty database, fresh WordPress install), run `make clean` (or `make fclean` for a full image/data wipe) followed by `make`.
