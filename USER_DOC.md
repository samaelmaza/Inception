# User Documentation

## 1. Services Provided by the Stack
This infrastructure provides a complete, modern web stack hosted inside isolated Docker containers:
- **WordPress**: The main website/blog platform.
- **MariaDB**: The database storing all website data.
- **NGINX**: The web server securely exposing the website over HTTPS (TLSv1.3).
- **Redis Cache**: A memory cache to speed up website loading times.
- **FTP Server (vsftpd)**: A remote file transfer service to manage website files directly.
- **Adminer**: A lightweight, web-based database management interface.
- **Static Portfolio**: A static HTML/CSS portfolio served via Python.
- **Monitoring Dashboard**: A live system dashboard tracking CPU and RAM usage.

## 2. Starting and Stopping the Project
- **To Start**: Navigate to the root directory and run `make`. This will build and launch all services in the background.
- **To Stop**: Run `make down` to cleanly stop the containers while preserving your data. To completely destroy the containers and volumes, run `make fclean`.

## 3. Accessing the Services
- **Main Website**: `https://sreffers.42.fr` (Ignore the self-signed certificate warning).
- **WordPress Admin Panel**: `https://sreffers.42.fr/wp-admin`
- **Adminer (Database GUI)**: `http://sreffers.42.fr:8080`
- **Static Portfolio**: `http://sreffers.42.fr:3000`
- **Monitoring Dashboard**: `http://sreffers.42.fr:8081`

## 4. Locating and Managing Credentials
All credentials (passwords) are strictly managed using Docker Secrets and `.env` files for security.
- **Environment Variables**: Managed in `srcs/.env` (contains usernames and database names).
- **Passwords**: Stored as plaintext files in the `secrets/` directory at the root of the project:
  - `db_password.txt`: MariaDB `wp_user` password.
  - `db_root_password.txt`: MariaDB `root` password.
  - `wp_admin_password.txt`: WordPress Administrator password.
  - `ftp_password.txt`: FTP user password.

## 5. Checking that Services are Running Correctly
To verify the health of the infrastructure:
1. Open a terminal in the project directory.
2. Run `docker ps` to see all running containers. You should see 8 containers with the status `Up`.
3. To view real-time logs for a specific service (e.g., NGINX), run: `docker compose -f srcs/docker-compose.yml logs -f nginx`.
