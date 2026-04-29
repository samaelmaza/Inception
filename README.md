*This project has been created as part of the 42 curriculum by sreffers.*

# Inception

## Description
The Inception project is a comprehensive System Administration and DevOps challenge. The goal is to broaden your knowledge of system administration by using Docker to set up a small, isolated infrastructure. You will virtualize several Docker images, creating them in your new personal virtual machine. The core infrastructure consists of a NGINX web server, a WordPress instance, and a MariaDB database, entirely built from scratch using Debian base images.

## Instructions
### Compilation and Installation
1. Ensure `docker` and `docker-compose` are installed on your machine.
2. Modify your `/etc/hosts` file to map `127.0.0.1` to `sreffers.42.fr`.
3. Create a `secrets/` folder at the root with the required password files (`db_password.txt`, `db_root_password.txt`, `wp_admin_password.txt`, `ftp_password.txt`).
4. Ensure the `srcs/.env` file is properly configured.

### Execution
- To start the entire infrastructure in the background:
  ```bash
  make
  ```
- To safely stop the services:
  ```bash
  make down
  ```
- To stop the services and wipe all data and volumes:
  ```bash
  make fclean
  ```

## Resources
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WP-CLI Documentation](https://make.wordpress.org/cli/handbook/)

### Use of AI
AI (Antigravity by Google DeepMind) was used as a pedagogical pair-programmer throughout this project. It was utilized for:
- Explaining complex Docker concepts (networks, PID 1, volumes vs bind mounts).
- Assisting in debugging configuration syntax errors (e.g., Dockerfile ENTRYPOINT JSON formatting).
- Providing structural templates for Bash setup scripts and the custom Python monitoring dashboard.
- Translating and formatting markdown documentation.

## Project Description & Technical Choices
This project utilizes Docker to orchestrate a modular architecture. All images are built from `debian:bullseye` to ensure consistency and stability. 
Key design choices include:
- **No official pre-configured images**: Every service (MariaDB, WordPress, NGINX, Redis, FTP, Adminer, etc.) was built from a raw Debian base image using custom Dockerfiles and Bash setup scripts.
- **Idempotency**: All initialization scripts (`setup.sh`) are designed to run safely multiple times without corrupting existing data.
- **WP-CLI**: Used to automatically configure WordPress and integrate the Redis cache programmatically without user interaction.

### Concept Comparisons

#### Virtual Machines vs Docker
- **Virtual Machines (VMs)** emulate an entire computer system, including the hardware and a full guest operating system. They are heavy and resource-intensive.
- **Docker** containerizes applications by isolating them at the process level. Containers share the host's Linux Kernel (e.g., `/proc`), making them extremely lightweight, fast to boot, and highly portable.

#### Secrets vs Environment Variables
- **Environment Variables** are easily exposed. Anyone who can inspect the container (`docker inspect`) or view the system processes can read them. They are suitable for non-sensitive config (like Domain Names).
- **Docker Secrets** (or file-based secrets) mount sensitive data as temporary files directly in the container's memory (`/run/secrets/`). They are never stored in the image history or exposed in clear text during configuration, making them the standard for passwords.

#### Docker Network vs Host Network
- **Host Network** removes isolation. The container shares the host's IP and ports directly, which can lead to port conflicts and security risks.
- **Docker Network** (Bridge network, used in this project as `inception`) creates a private, isolated subnet. Containers can resolve each other by name (e.g., NGINX can reach `wordpress:9000`), and only explicitly published ports (like NGINX `443:443`) are exposed to the outside world.

#### Docker Volumes vs Bind Mounts
- **Docker Volumes** are entirely managed by Docker (usually stored in `/var/lib/docker/volumes/`). They are the safest way to persist data, abstracting the host filesystem away.
- **Bind Mounts** explicitly link a specific directory on the host (e.g., `/home/sam/data/wordpress`) to a directory in the container. While less abstracted, they provide easier direct access to files from the host machine, which was required by the subject's specifications.
