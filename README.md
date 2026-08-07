*This project has been created as part of the 42 curriculum by schahir.*

# Inception

## Description

Inception is a system administration project whose goal is to deploy a small, containerized web infrastructure using Docker and Docker Compose, built entirely from scratch.

The stack sets up a WordPress site served over HTTPS, backed by a MariaDB database, with each service isolated in its own container built from a custom Dockerfile (no pre-built images pulled from Docker Hub, aside from the base Alpine/Debian image).

**Mandatory services:**
- **NGINX** — the single entry point of the infrastructure, serving WordPress over HTTPS (TLSv1.2/TLSv1.3) on port 443.
- **WordPress + php-fpm** — the CMS application, running without a bundled web server, communicating with NGINX over FastCGI.
- **MariaDB** — the database engine backing WordPress, with no web server installed.

**Bonus services:**
- **Redis** — object cache for WordPress, reducing database load.
- **FTP server** — provides FTP access to the WordPress volume for file management.
- **Static website** — a small standalone site (non-PHP) served independently.
- **Adminer** — a lightweight web UI for inspecting/administering the MariaDB database.
- **Portainer** — a web UI for managing and monitoring the Docker environment itself.

All containers communicate over a dedicated Docker bridge network, and persistent data (the WordPress database and website files) is stored in Docker named volumes bind-mounted to `/home/schahir/data` on the host.

## Instructions

### Prerequisites
- A Linux virtual machine
- Docker and the Docker Compose plugin installed
- Root/sudo privileges (needed to write the host `/etc/hosts` entry and manage the data directory)

### Setup
1. Clone the repository.
2. Add the domain to your local DNS resolution so it points to the machine's own IP:
   ```
   127.0.0.1   schahir.42.fr
   ```
   (add this line to `/etc/hosts`)
3. Review/adjust the variables in `srcs/.env` if needed (database credentials, WordPress admin, FTP credentials, domain name). Example `.env`:
   ```
   MARIA_DB_NAME=maria
   USER=umaria
   USER_PASSWORD=123
   ROOT_PASSWORD=123

   WORDPRESS_DB_HOST=wordpress

   DOMAIN_NAME=schahir.42.fr
   WP_ADMIN_USER=auser
   WP_ADMIN_EMAIL=amail@student.1337.fr

   WP_USER=wpuser
   WP_USER_EMAIL=wpuser@gmail.com

   WP_USER_PASSWORD=123
   WP_ADMIN_PASSWORD=123
   WP_PASSWORD=123

   FTP_USER=fuser
   FTP_PASSWORD=123
   ```
   This file must never be committed to git — keep it listed in `.gitignore`.

### Build and run
```bash
make        # builds all images and starts every container in detached mode
```

### Stop / clean up
```bash
make down    # stops and removes the containers
make clean   # stops the containers and removes the associated volumes
make fclean  # full clean: removes containers, volumes, images, and the host data directory
make re      # fclean followed by all
```

### Access
- Website: https://schahir.42.fr
- WordPress admin panel: https://schahir.42.fr/wp-admin
- Adminer: http://schahir.42.fr:8080 (or the mapped port)
- Portainer: https://schahir.42.fr:9443
- Static website: http://schahir.42.fr:8085
- FTP: port 21 (+ passive port range 10000–11000), connecting to the WordPress volume

See `USER_DOC.md` and `DEV_DOC.md` for detailed usage and setup instructions.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI (WP-CLI) documentation](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- 42 Inception subject PDF (provided by the school)

**AI usage:** An AI assistant was used as a support tool during this project, mainly to help debug Docker entrypoint scripts and NGINX configuration issues, to clarify how WP-CLI automation commands work, and to build a deeper conceptual understanding of how the stack fits together end-to-end (DNS resolution, TLS handshake, FastCGI communication between NGINX and PHP-FPM, and MariaDB internals). All AI-assisted explanations were cross-checked against official documentation and tested manually before being relied upon; no code was used without being fully understood.

## Project description: Docker design choices

This project relies entirely on Docker to build and orchestrate the infrastructure. Each service (NGINX, WordPress/php-fpm, MariaDB, and the bonus services) has its own Dockerfile, built from the penultimate stable Debian/Alpine image, with no dependency on pre-built third-party images. The containers are wired together through a single custom Docker network (`inception`), and persistent data is handled through named volumes.

### Virtual Machines vs Docker

| | Virtual Machine | Docker |
|---|---|---|
| Isolation | Full OS-level isolation, own kernel | Process-level isolation, shares host kernel |
| Resource usage | Heavier (each VM boots a full OS) | Lightweight, faster startup |
| Portability | Less portable, larger images | Highly portable, images are small and reproducible |
| Use case here | Hosts the whole Docker environment | Runs each individual service in isolation |

The project runs *inside* a VM, but each service within it is containerized rather than given its own VM. This is more efficient: containers start in seconds, share the host kernel, and consume far fewer resources than spinning up a VM per service, while still keeping each service's filesystem, processes, and dependencies isolated from the others.

### Secrets vs Environment Variables

Environment variables (via the `.env` file, loaded through `env_file` in `docker-compose.yml`) are used to configure the containers — domain name, database name/user, WordPress admin/user info, and FTP credentials. This keeps configuration out of the Dockerfiles and out of version control (the `.env` file is git-ignored).

Docker secrets go a step further: rather than being exposed as process environment variables (visible via `docker inspect` or `/proc/<pid>/environ`), secrets are mounted as files inside the container's filesystem at runtime and only readable by the target process, which reduces the exposure surface for sensitive values like passwords. Environment variables are simpler to wire up and sufficient for non-critical configuration values, while secrets are the safer choice specifically for credentials and other sensitive data.

### Docker Network vs Host Network

The project uses a dedicated user-defined bridge network (`inception`) rather than `network: host`. With a custom network, containers get their own private IP addresses and communicate with each other by service name (Docker's internal DNS), while only the ports explicitly published (443, 8080, 9443, 8085, 21, 10000–11000) are exposed to the host. Host networking, by contrast, would remove that isolation entirely — every container would share the host's network stack directly, which is both a security risk and explicitly forbidden by the project subject.

### Docker Volumes vs Bind Mounts

Two named volumes (`mariadb_data` and `wordpress_data`) are used to persist the database and the WordPress files. Named volumes are managed by Docker itself, are more portable across environments, and are decoupled from a specific host path in the Compose file syntax — even though, per the subject's requirement, their backing storage is explicitly pinned to `/home/schahir/data` on the host via `driver_opts`.

Bind mounts, which map a container path directly to an arbitrary host path, are simpler but tie the setup more tightly to the host filesystem's exact layout/permissions and are not managed by Docker's volume lifecycle (`docker volume ls/rm/prune`, etc.). The subject explicitly requires named volumes for the two persistent stores, which is what this project uses.
