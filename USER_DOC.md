*This project has been created as part of the 42 curriculum by schahir.*

# User Documentation

This document explains, from an end user or administrator's point of view, how to use the Inception stack: what it provides, how to start/stop it, how to access it, and how to check that everything is working.

## 1. What services does the stack provide?

| Service | Role | How you'd notice it |
|---|---|---|
| NGINX | The only entry point into the stack, serves everything over HTTPS | You visit `https://schahir.42.fr` |
| WordPress | The website/CMS itself | The blog/site content and the admin dashboard |
| MariaDB | Stores all WordPress data (posts, users, settings) | Invisible to you directly, but everything WordPress shows comes from here |
| Redis | Speeds up WordPress by caching data | Faster page loads, no direct UI |
| Adminer | A web UI to browse/manage the MariaDB database | `http://schahir.42.fr:8080` |
| FTP server | Lets you upload/download WordPress files directly | Connect with any FTP client |
| Static website | A separate, simple non-PHP showcase site | `http://schahir.42.fr:8085` |
| Portainer | A web UI to see/manage all running containers | `https://schahir.42.fr:9443` |

## 2. Starting and stopping the project

All commands are run from the root of the repository, where the `Makefile` lives.

**Start everything** (builds images if needed, then starts all containers in the background):
```bash
make
```

**Stop the containers** (keeps your data):
```bash
make down
```

**Stop and wipe the data volumes** (fresh database/website next time):
```bash
make clean
```

**Full reset** (containers, volumes, images, and the host data folder):
```bash
make fclean
```

**Rebuild everything from a clean state:**
```bash
make re
```

## 3. Accessing the website and the administration panel

Before your first visit, make sure the domain resolves to your machine. Add this line to your `/etc/hosts` file (needs sudo):
```
127.0.0.1   schahir.42.fr
```

Then, once the stack is running:

- **Website:** open `https://schahir.42.fr` in your browser. Your browser will likely warn you about the certificate — this is expected since it's a self-signed certificate for local development; you can safely proceed for this exercise.
- **WordPress admin panel:** go to `https://schahir.42.fr/wp-admin` and log in with your WordPress admin or WordPress user credentials (see next section for where to find them).
- **Adminer (database UI):** `http://schahir.42.fr:8080` — log in using the MariaDB credentials, with the server field set to `mariadb`.
- **Portainer (container management UI):** `https://schahir.42.fr:9443` — the first time you open it you'll be asked to create a Portainer admin account.
- **Static showcase site:** `http://schahir.42.fr:8085`.
- **FTP access:** connect any FTP client to `schahir.42.fr` on port 21 using the FTP credentials below. This gives direct access to the WordPress files volume.

## 4. Locating and managing credentials

All credentials are defined as environment variables in the `srcs/.env` file at the root of the `srcs` folder. This file is intentionally excluded from version control (git-ignored) since it contains sensitive values.

It defines, among others:
- The MariaDB database name, user, and passwords (regular user + root)
- The WordPress admin username, email, and password
- A second, non-admin WordPress user (username, email, password)
- The FTP username and password
- The domain name used by the stack

If you need to change a credential, edit `srcs/.env` and re-run `make re` so the containers pick up the new values (existing data in the volumes is preserved unless you also run `make clean`/`make fclean`).

> Note: per the project's admin-naming rule, the WordPress administrator's username must not contain "admin" or "administrator" in any casing.

## 5. Checking that the services are running correctly

**Check container status:**
```bash
docker ps
```
You should see one running container per service (`nginx`, `wordpress`, `mariadb`, `redis`, `adminer`, `ftp`, `website`, `portainer`), all with a status of `Up`.

**Check container logs** if something looks wrong:
```bash
docker logs <container_name>
```
For example, `docker logs nginx` or `docker logs wordpress`.

**Quick health checks:**
- Visiting `https://schahir.42.fr` returns the WordPress site (not a connection error or a blank NGINX page).
- Logging into `/wp-admin` succeeds with the credentials from `.env`.
- Adminer can connect to the `mariadb` service and shows the WordPress database and its tables.
- `docker volume ls` shows the `mariadb_data` and `wordpress_data` named volumes, and `/home/schahir/data/mariadb` and `/home/schahir/data/wordpress` exist and contain data on the host.

If a service repeatedly restarts, check its logs first — this is almost always caused by a misconfigured environment variable or a dependency (e.g., MariaDB) not being ready yet when the dependent service starts.
