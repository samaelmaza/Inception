# Developer Documentation

## 1. Setting up the Environment from Scratch
Before running the project, ensure your host environment is properly configured.

### Prerequisites
- Operating System: Debian or a compatible Linux distribution (or a Virtual Machine).
- Software: `docker`, `docker-compose`, and `make`.
- Host DNS: You must route the domain `sreffers.42.fr` to `127.0.0.1`. Add this line to your `/etc/hosts` file:
  `127.0.0.1 sreffers.42.fr`

### Configuration Files and Secrets
1. Navigate to the root directory.
2. Ensure the `.env` file is present in `srcs/.env` with the necessary configuration variables (`DOMAIN_NAME`, `MYSQL_DATABASE`, etc.).
3. Ensure the `secrets/` directory exists at the root and contains the necessary password files (`db_password.txt`, `db_root_password.txt`, `wp_admin_password.txt`, `ftp_password.txt`).

## 2. Building and Launching the Project
The project uses a `Makefile` at the root to abstract Docker Compose commands.
- **Build and Launch**: `make` or `make up`. This command creates the `data` folders on the host, builds the Docker images from the Dockerfiles located in `srcs/requirements/`, and launches the containers in detached mode.
- **Rebuild from scratch**: `make re`. This stops, cleans everything, and rebuilds the infrastructure.

## 3. Container and Volume Management
To manage the infrastructure as a developer, you can use the Makefile or raw Docker commands:
- **View Containers**: `docker ps -a`
- **Stop Services**: `make down` (or `cd srcs && docker compose down`)
- **Access a Container's Shell**: `docker exec -it <container_name> /bin/bash`
- **View Volumes**: `docker volume ls`
- **Clean all Docker resources (System Prune)**: `make clean`

## 4. Project Data Storage and Persistence
Docker relies on volumes to ensure data persists even if the containers are destroyed.
In this project, data is persisted using bind-mounted directories on the host machine.
- **Storage Location**: By default, data is mapped to `/home/sam/data/` on the host.
- **Database Data**: Stored in `/home/sam/data/mariadb/`. This ensures the WordPress database survives container restarts.
- **Website Files**: Stored in `/home/sam/data/wordpress/`. This allows NGINX and the FTP server to access the PHP files, and persists uploaded media.
