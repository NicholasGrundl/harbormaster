# VPS Structure Review and Implementation

## Current VPS Structure
```bash
/home/youruser/
├── docker-compose.yml
└── config/
    ├── keys/
    │   ├── dockmaster.key    # Production JWT signing key
    │   ├── dockyard.key      # Production JWT signing key
    │   └── gcp-key.json      # GCP service account key
    └── nginx/
        └── ssl/              # SSL certificates
```

## Recommended VPS Structure
```bash
/home/youruser/
├── app/                      # Main application directory
│   ├── docker-compose.yml    # Production compose file
│   └── .env                  # Production environment variables
│
├── config/                   # Configuration directory
│   ├── keys/                # Service keys
│   │   ├── dockmaster.key   # Dockmaster JWT signing key
│   │   ├── dockyard.key     # Dockyard JWT signing key
│   │   └── gcp-key.json     # GCP service account key
│   │
│   └── nginx/               # Nginx configurations
│       ├── conf.d/          # Nginx site configurations
│       └── ssl/             # SSL certificates
│
├── data/                     # Persistent data
│   └── volumes/             # Docker volumes
│       └── backend_data/    # Persistent backend storage
│
└── scripts/                  # Maintenance scripts
    ├── backup.sh            # Simple backup script
    └── update.sh            # Update deployment script
```

## Key Changes and Rationale

1. **Directory Organization**
   - Added `app/` directory to contain deployment files
   - Separated `data/` for persistent storage
   - Added basic maintenance scripts
   - Clearer separation between config, data, and application

2. **Access Control**
```bash
# Directory Permissions
app/            # 755 (rwxr-xr-x)
config/         # 750 (rwxr-x---)
config/keys/    # 700 (rwx------)
data/           # 750 (rwxr-x---)
scripts/        # 750 (rwxr-x---)

# File Permissions
*.key           # 600 (rw-------)
*.json          # 600 (rw-------)
docker-compose.yml  # 644 (rw-r--r--)
.env            # 600 (rw-------)
```

## Example Docker Compose File Location
```bash
/home/youruser/app/docker-compose.yml
```
```yaml
version: '3.8'

services:
  dockmaster:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_AUTH}:${IMAGE_TAG}
    user: "${UID}:${GID}"
    volumes:
      - ../config/keys/dockmaster.key:/app/keys/dockmaster.key:ro
      - ../config/keys/gcp-key.json:/app/keys/gcp-key.json:ro
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockmaster.key
      - GOOGLE_APPLICATION_CREDENTIALS=/app/keys/gcp-key.json
    security_opt:
      - no-new-privileges:true

  # ... other services ...

volumes:
  backend_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/youruser/data/volumes/backend_data
```

## Initial VPS Setup Steps

1. **Create Directory Structure**
```bash
# Create directories
mkdir -p ~/app
mkdir -p ~/config/keys
mkdir -p ~/config/nginx/{conf.d,ssl}
mkdir -p ~/data/volumes/backend_data
mkdir -p ~/scripts

# Set directory permissions
chmod 755 ~/app
chmod 750 ~/config ~/data ~/scripts
chmod 700 ~/config/keys

# Create necessary files
touch ~/app/.env
touch ~/config/keys/{dockmaster.key,dockyard.key,gcp-key.json}

# Set file permissions
chmod 600 ~/config/keys/*
chmod 600 ~/app/.env
```

2. **Service Account Setup**
```bash
# Copy service account key
scp gcp-key.json youruser@your-vps:~/config/keys/
```

3. **SSL Certificate Setup**
```bash
# Initial SSL setup using Let's Encrypt
certbot certonly --webroot -w /var/www/html -d yourdomain.com
```

## Environment Variables
```bash
# /home/youruser/app/.env

# GCP Configuration
ARTIFACT_REGISTRY_HOST=gcr.io/your-project-id
IMAGE_TAG=stable

# Service Images
IMAGE_FRONTEND=waypoint
IMAGE_BACKEND=dockyard
IMAGE_AUTH=dockmaster

# User Configuration
UID=1000
GID=1000

# Domain Configuration
DOMAIN_NAME=yourdomain.com
```

## Security Notes

1. **File System Security**
   - All sensitive files are in `config/keys` with restricted permissions
   - Key files are only readable by the owner
   - Nginx config and SSL certs are separate from application config

2. **Docker Security**
   - Services run as non-root user
   - Read-only mounts for sensitive files
   - no-new-privileges security option enabled
   - Explicit volume paths for data persistence

3. **Access Control**
   - Limited directory permissions
   - Sensitive files isolated in protected directories
   - Clear separation between public and private content

## Basic Deployment Process

1. **Initial Setup**
```bash
# On VPS
cd ~
git clone https://github.com/yourusername/harbormaster.git tmp
cp tmp/environments/production/docker-compose.yml ~/app/
cp tmp/environments/production/.env.example ~/app/.env
rm -rf tmp
```

2. **Update/Deploy**
```bash
# On VPS
cd ~/app
docker-compose pull
docker-compose up -d
```

## Comments and Recommendations

1. The structured separation between `app`, `config`, and `data` makes the VPS easier to maintain and backup.

2. Using absolute paths in docker-compose volumes helps prevent path-related issues.

3. Keeping secrets in `~/config/keys` with strict permissions provides good security while remaining simple.

4. The `app` directory contains only deployment-related files, making it easier to update configurations.

5. Consider adding basic script for updates:
```bash
# ~/scripts/update.sh
#!/bin/bash
cd ~/app
docker-compose pull
docker-compose up -d
```

This structure provides a good balance between simplicity and security, while remaining easy to maintain manually. It can also serve as a foundation for future improvements (monitoring, automated deployments, etc.) without requiring significant restructuring.